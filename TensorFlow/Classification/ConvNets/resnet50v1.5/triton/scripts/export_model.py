#! /usr/bin/python

import tensorflow as tf
from tensorflow.python.compiler.tensorrt import trt_convert as trt
import argparse
import shutil, os

def create_parser():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--precision_mode',
        help='Precision mode for tf-trt conversion',
        type=str,
        default='FP32',
        choices=['FP16', 'FP32']
    )
    parser.add_argument(
        '--saved_model_dir',
        help='Directory of the already saved model',
        type=str,
        default='./triton/model/saved_model/nvidia_rn50_tf_amp'
    )
    parser.add_argument(
        '--export_tftrt_dir',
        help='Directory where tftrt will be exported',
        type=str,
        default='./triton/model/tftrt'
    )
    parser.add_argument(
        '--infer_model_dir',
        help='Directory where tftrt model will be copied for inferencing',
        type=str,
        default='./triton/inference/resnet50/1/model.savedmodel/'
    )
    return parser

def export(FLAGS):

    print('[*] Converting Saved Model to TF-TRT ...')
    converter = trt.TrtGraphConverter(
        input_saved_model_dir=FLAGS.saved_model_dir,
        input_saved_model_tags=['serve'],
        input_saved_model_signature_key='serving_default',
        precision_mode=FLAGS.precision_mode,
        max_workspace_size_bytes=(2 < 32),  # 8,589,934,592 bytes
        maximum_cached_engines=100,
        minimum_segment_size=3,
        is_dynamic_op=True
      )
    converter.convert()
    converter.save(FLAGS.export_tftrt_dir)

    print(f'[*] Tftrt Saved Model exported to {FLAGS.export_tftrt_dir}')

if __name__ == '__main__':
    FLAGS = create_parser().parse_args()

    # Remove all previous exported TF-TRT models and create a new directory
    os.chdir('/resnet50')
    if os.path.isdir(FLAGS.export_tftrt_dir):
        print("Removing previous exported models from ", FLAGS.export_tftrt_dir)
        shutil.rmtree(FLAGS.export_tftrt_dir)
    
    # Create a new directory to save model in
    os.mkdir(FLAGS.export_tftrt_dir)
    export(FLAGS)

    # Copy the newly created TF-TRT model to the folder mounted for inferencing services
    shutil.copyfile(os.path.join(FLAGS.export_tftrt_dir, "saved_model.pb"), os.path.join(FLAGS.infer_model_dir, "saved_model.pb"))
    #shutil.rmtree(os.path.join(FLAGS.infer_model_dir, "variables"))
    #os.mkdir(os.path.join(FLAGS.infer_model_dir, "variables"))

    print(f'[*] Tftrt Saved Model copied to {FLAGS.infer_model_dir} for use in inferencing service')
