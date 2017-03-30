#!/bin/sh
cd /media/nfs/extend/ssd/caffe
./build/tools/caffe train \
	--solver="models/VGGNet/VOC0712/SSD_300x300_score/solver.prototxt" \
	--weights="models/VGGNet/VOC0712/SSD_300x300/VGG_VOC0712_SSD_300x300_iter_36866.caffemodel" \
	--gpu 0 2>&1 | tee jobs/VGGNet/VOC0712/SSD_300x300_score/VGG_VOC0712_SSD_300x300_test36866.log
