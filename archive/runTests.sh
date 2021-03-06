#!/bin/bash
wget -q https://raw.githubusercontent.com/toddawhittaker/PHPMimirTestRunner/master/bin.zip
unzip -q bin.zip
chmod a+x bin/*
mv bin/* /bin

# simple syntax check
for file in *.php; do
  status="$(php -l $file 2>&1)"
  if [ $? -ne 0 ]; then
    echo "$status" >> DEBUG
    echo 0 >> OUTPUT
    exit 1
  fi
done

debug=$(phpunit.phar --log-teamcity output.log .)
tests=$(grep 'testStarted' output.log | wc -l)
failures=$(grep 'testFailed' output.log | wc -l)
((passing = $tests - $failures))
((score = $passing * 100 / $tests))
echo "You passed $passing out of $tests tests, earning $score% of possible points." >> DEBUG
echo "See below for detailed testing results to help you debug." >> DEBUG
echo "----------------------------------------------------------" >> DEBUG
echo "" >> DEBUG
echo "$debug" >> DEBUG
echo "$score" > OUTPUT
