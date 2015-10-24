prototxt_template = 'template.prototxt'
solver_template = 'solver_template.prototxt'
file_name = '%s_vg_m1_fgnet_chalearn_train_val.prototxt'
solver_name = '%s_vg_m1_fgnet_chalearn_solver.prototxt'

PREFIX = '1'
imagenet = 'path/to/imagenet.binaryproto'
snapshot_prefix = 'path/to/results/vgg_m1_fgnet_chalearn_' + PREFIX + '_%s'

source_path = 'path/to/source/'
source_aug_train = source_path + PREFIX + '_%s_age_m1_fgnet_chalearn_aug_train.txt'
source_train = source_path + PREFIX + '_%s_age_m1_fgnet_chalearn_train.txt'
source_test = source_path + PREFIX + '_%s_age_m1_fgnet_chalearn_test.txt'

caffe_path = '/path/to/caffe/build/tools/caffe'
weights_path = 'path/to/vgg_m1_wiki_imdb_equal_iter_500000.caffemodel'

with open(prototxt_template, 'r') as f:
    prototxt_lines = f.readlines()

with open(solver_template, 'r') as f:
    solver_lines = f.readlines()


for i in range(1, 83):
    fold = str(i)
    with open(file_name % fold, 'w') as f:
        for l in prototxt_lines:
            l = l.replace('MEAN_FILE', imagenet)
            l = l.replace('source: AUG_TRAIN', source_aug_train % fold)
            l = l.replace('source: TRAIN', source_train % fold)
            l = l.replace('source: TEST', source_test % fold)
            f.write(l)

    with open(solver_name % fold, 'w') as f:
        for l in solver_lines:
            l = l.replace('NET', file_name % fold)
            l = l.replace('PREFIX', snapshot_prefix % fold)
            f.write(l)

    with open('run_experiment_%s.sh' % fold, 'r') as f:
        f.write('train'
                ' -solver ' + solver_name % fold +
                ' -weights ' + weights_path +
                ' 2>&1 | tee %s_%s.txt\n' % (PREFIX, fold))
    break



