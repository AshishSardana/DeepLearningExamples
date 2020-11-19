import argparse
import os
import shutil
import tensorflow as tf
import tensorflow_transform as tft
from inference.utils.features import get_features_keys, get_feature_columns


def create_parser():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--model_name',
        help='Name of the model',
        type=str,
        default='widedeep'
    )
    parser.add_argument(
        '--export_dir',
        help='Path to exported model directory',
        type=str,
        default='./models/tftrt/1588932335'
    )
    parser.add_argument(
        '--model_dir',
        help='Path where triton config will be stored',
        type=str,
        default='./inference/models'
    )
    parser.add_argument(
        '--max_batch_size',
        help='Max batch for inference',
        type=int,
        default='1048576'
    )
    parser.add_argument(
        '--transformed_metadata_path',
        help='Path to transformed_metadata for feature specification reconstruction',
        type=str,
        default='./outbrain/tfrecords'
    )

    return parser


def _indent(number):
    return number * ' '


def saved_model_config_template(model_name, platform, max_batch_size, input, output):
    lines = [
        f'name: "{model_name}"',
        f'platform: "{platform}"',
        f'max_batch_size: {max_batch_size}',
        f'{input}',
        f'{output}'
    ]
    return f'{os.linesep}'.join(lines)


def saved_model_input_template():
    lines = ['input [']
    feature_spec = tft.TFTransformOutput(
        FLAGS.transformed_metadata_path
    ).transformed_feature_spec()
    feature_keys = get_features_keys()
    for feature_name, tensor in feature_spec.items():
        if feature_name in feature_keys:
            new_lines = [
                f'{_indent(2)}{"{"}',
                f'{_indent(4)}name: "{feature_name}"',
                f'{_indent(4)}data_type: {"TYPE_FP32" if tensor.dtype == tf.float32 else "TYPE_INT64"}',
                f'{_indent(4)}dims: [ {tensor.shape[-1]} ]',
                f'{_indent(2)}{"}"},'
            ]
            lines.extend(new_lines)
    lines[-1] = f'{_indent(2)}{"}"}'  # remove ',' from last feature
    lines.append(']')
    return f'{os.linesep}'.join(lines)


def saved_model_output_template():
    lines = [
        'output [',
        f'{_indent(2)}{"{"}',
        f'{_indent(4)}name: "probabilities"',
        f'{_indent(4)}data_type: TYPE_FP32',
        f'{_indent(4)}dims: [ 2 ]',
        f'{_indent(2)}{"}"}',
        ']'
    ]
    return f'{os.linesep}'.join(lines)


def create_directory_hierarchy(config, model_dir, export_dir, model_name):
    if os.path.exists(model_dir) and os.path.isdir(model_dir):
        print(f'[*] Models directory {model_dir} already exists, removing ...')
        shutil.rmtree(model_dir)
    config_root = os.path.join(model_dir, model_name)
    config_path = os.path.join(config_root, 'config.pbtxt')
    model_path = os.path.join(config_root, "1", "model.savedmodel")
    shutil.copytree(export_dir, model_path)
    print(f'[*] Models hierarchy {model_path} created from model {export_dir}')
    with open(config_path, 'w') as config_file:
        config_file.write(config)
    print(f'[*] Config file {config_path} created')


def main(FLAGS):
    assert os.path.exists(FLAGS.export_dir) and os.path.isdir(FLAGS.export_dir), \
        f'Model not found in file {FLAGS.export_dir}'
    config = saved_model_config_template(
        model_name=FLAGS.model_name,
        platform="tensorflow_savedmodel",
        max_batch_size=FLAGS.max_batch_size,
        input=saved_model_input_template(),
        output=saved_model_output_template()
    )
    create_directory_hierarchy(
        config=config,
        model_dir=FLAGS.model_dir,
        export_dir=FLAGS.export_dir,
        model_name=FLAGS.model_name
    )


if __name__ == '__main__':
    FLAGS = create_parser().parse_args()
    main(FLAGS)
