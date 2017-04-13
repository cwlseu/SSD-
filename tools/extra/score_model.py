#!/usr/bin/env python
#-*- encoding:utf-8 -*-

import os
import shutil
import stat
import subprocess
import sys


def make_if_not_exist(path):
  if not os.path.exists(path):
    os.makedirs(path)


def list_dir(path, suffix='.caffemodel'):
  l = os.listdir(path)  # 列出目录下的所有文件和目录
  result = []
  for line in l:
    if line.endswith(suffix):
      result.append(os.path.join(path, line))
  return result

caffe_root = "/home/nfs/caffe"
model_dir = os.path.join(caffe_root, "models")
solver_file = "models/VGGNet/VOC0712/SSD_300x300_score/solver.prototxt"
job_dir = "jobs/VGGNet/VOC0712/SSD_300x300_score"


def create_score_model_script(model, gpu=True):
    # job script path.
  model_name, _ = os.path.splitext(model)
  job_file = "{}/{}.sh".format(job_dir, model_name)
  with open(job_file, 'w') as f:
    f.write('cd {}\n'.format(caffe_root))
    f.write('./build/tools/caffe train \\\n')
    f.write('--solver="{}" \\\n'.format(solver_file))
    f.write('--weights="{}" \\\n'.format(os.path.join(model_dir, model)))
    if gpu:
      f.write('--gpu 0 1 2>&1 | tee {}/{}.log\n'.format(model_dir, model_name))
    else:
      f.write('2>&1 | tee {}/{}.log\n'.format(job_dir, model_name))
  os.chmod(job_file, stat.S_IRWXU)
  return job_file


def main():
  make_if_not_exist(job_dir)
  models = list_dir(model_dir, ".caffemodel")
  l = len(models)
  for model in sorted(models):
    job_file = create_score_model_script(model=model, gpu=True)
    subprocess.call(job_file, shell=True)
  # jobs = list_dir(model_dir, ".sh")
  # for job_file in jobs:
  #     subprocess.call(job_file, shell=True)

if __name__ == '__main__':
  main()
