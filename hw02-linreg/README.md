## a vowpal wabbit solution to the linear regression homework

First, get all the data conveniently below our working directory. It is .gitignore'd so that it isn't redundant.

```bash
git clone https://github.com/arahuja/GADS4.git
```

The smaller training files were experimented with while working on this, but just the 200k will be manipulated here for brevity.

```bash
./add_loc.py GADS4/data/kaggle_salary/train_200k.csv data/trainall.csv
./add_loc.py GADS4/data/kaggle_salary/test.csv data/test.csv
```

For simplicity, I'm omitting a further randomization of row order which would probably be nice to do. Let's just convert to vw format now.

```bash
./vw-ize.py data/trainall.csv > data/trainall.vw
./vw-ize.py data/test.csv > data/test.vw
```

Now we can split out our local train and test from all the training data.

```bash
head -195000 data/trainall.vw > data/train.vw
tail +195001 data/trainall.vw > data/valid.vw
```

Models were trained and tested many many times. This is the current one, after having been determined based on a reasonable starting point and experimental iteration to get higher performance. It could be improved further, most likely, with a real systematic grid search for hyperparameters. Here it is trained and tested on the train and test sets split from the original 200k training file. (No part of this relies on having the true labels for the hold-out test set.) (Consult the [documentation for vw](https://github.com/JohnLangford/vowpal_wabbit/wiki) to understand what's happening.)

```bash
# Train model:
vw data/train.vw --passes 100 -k --cache_file models/c -f models/model -b 24 --l1 0.0000001
# Make predictions:
vw -i models/model -t data/valid.vw -k -p models/predict
# Evaluate MAE, specifying 5,000 entries for averaging:
# (This is super inefficient and difficult to read and should be changed.)
echo `paste -d- <(cat models/predict | while read line; do echo "e($line)" | bc -l; done) <(cut -d' ' -f1 data/valid.vw | while read line; do echo "e($line)" | bc -l; done) | bc -l | tr -d '-' | paste -sd+ - | bc -l`/5000 | bc -l
```

The final output is the MAE of 6,054 on the local test set. Not bad. We proceed to final predictions with a model trained on the whole data set. (The final evaluation will not work without the complete (labeled) test set, which is not available.)

```bash
vw data/trainall.vw --passes 100 -k --cache_file models/c -f models/model -b 24 --l1 0.0000001
vw -i models/model -t data/test.vw -p models/submission
echo "Id,Salary" > models/submission.csv
paste -d, <(tail +2 data/test.csv | cut -d, -f1) <(cat models/submission | while read line; do echo "e($line)" | bc -l; done) >> models/submission.csv
./eval.py models/submission.csv
```

This submission has an MAE of 6,888.
