import argparse
import os
import tensorflow as tf
import tensorflow_transform as tft
import time
from inference.utils.features import get_features_keys, get_feature_columns
from tensorflow.python.compiler.tensorrt import trt_convert as trt
from trainer.task import custom_estimator_model_fn

MODEL_TYPE = 'wide_n_deep'


def create_parser():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--precision_mode',
        help='Precision mode for tf-trt conversion',
        type=str,
        default='FP16',
        choices=['FP16', 'FP32']
    )
    parser.add_argument(
        '--checkpoint_dir',
        help='Path to directory with current checkpoint',
        type=str,
        default='./outbrain/checkpoints'
    )
    parser.add_argument(
        '--export_saved_model_dir',
        help='Directory where SavedModel will be exported',
        type=str,
        default='./models/saved_model'
    )
    parser.add_argument(
        '--export_tftrt_dir',
        help='Directory where tftrt will be exported',
        type=str,
        default='./models/tftrt'
    )
    parser.add_argument(
        '--transformed_metadata_path',
        help='Path to transformed_metadata for feature specification reconstruction',
        type=str,
        default='./outbrain/tfrecords'
    )
    parser.add_argument(
        '--deep_hidden_units',
        help='Hidden units per layer, separated by spaces',
        default=[1024, 1024, 1024, 1024, 1024],
        type=int,
        nargs="+")
    parser.add_argument(
        '--deep_dropout',
        help='Dropout regularization for deep model',
        type=float,
        default=0.0)

    return parser


def export(FLAGS):
    wide_columns, deep_columns = get_feature_columns()

    estimator = tf.estimator.Estimator(
        model_fn=custom_estimator_model_fn,
        model_dir=FLAGS.checkpoint_dir,
        params={
            'wide_columns': wide_columns,
            'deep_columns': deep_columns,
            'deep_dropout': FLAGS.deep_dropout,
            'model_type': MODEL_TYPE,
            'layers': FLAGS.deep_hidden_units
        })

    def serving_input_receiver_fn():
        feature_spec = tft.TFTransformOutput(
            FLAGS.transformed_metadata_path
        ).transformed_feature_spec()
        feature_keys = get_features_keys()

        features = {feature_name: tf.placeholder(dtype=tensor.dtype, shape=[None, tensor.shape[-1]], name=feature_name)
                    for feature_name, tensor in feature_spec.items()
                    if feature_name in feature_keys}

        return tf.estimator.export.ServingInputReceiver(
            features=features,
            receiver_tensors=features
        )

    print('[*] Exporting Checkpoint to Saved Model ...')
    exported_saved_model_dir = estimator.export_saved_model(
        export_dir_base=FLAGS.export_saved_model_dir,
        serving_input_receiver_fn=serving_input_receiver_fn
    )
    print(f'[*] SavedModel exported to {exported_saved_model_dir}')

    print('[*] Converting Saved Model to TF-TRT ...')
    converter = trt.TrtGraphConverter(
        input_saved_model_dir=exported_saved_model_dir,
        input_saved_model_tags=['serve'],
        input_saved_model_signature_key='predict',
        precision_mode=FLAGS.precision_mode
    )
    converter.convert()

    export_tftrt_dir_with_timestamp = os.path.join(FLAGS.export_tftrt_dir, str(int(time.time())))
    converter.save(
        output_saved_model_dir=export_tftrt_dir_with_timestamp
    )
    print(f'[*] Tftrt Saved Model exported to {export_tftrt_dir_with_timestamp}')


if __name__ == '__main__':
    FLAGS = create_parser().parse_args()
    export(FLAGS)
