# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#! /bin/bash

TEST_DIR=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )/../$STEP_NAME

# use example database config
if [ -a $TEST_DIR/config/settings.example.yml ]; then
  cp $TEST_DIR/config/settings.example.yml $TEST_DIR/config/settings.yml
fi

# use example settings config
if [ -a $TEST_DIR/config/database.example.yml ]; then
  cp $TEST_DIR/config/database.example.yml $TEST_DIR/config/database.yml
fi

if [ $STEP_NAME = '2-cloud-datastore' ]; then
  # download gcd testing tool
  wget -q http://storage.googleapis.com/gcd/tools/gcd-v1beta2-rev1-3.0.2.zip -O gcd-v1beta2-rev1-3.0.2.zip
  unzip -o gcd-v1beta2-rev1-3.0.2.zip

  # start gcd test server
  gcd-v1beta2-rev1-3.0.2/gcd.sh create -d gcd-test-dataset-directory gcd-test-dataset-directory
  gcd-v1beta2-rev1-3.0.2/gcd.sh start --testing ./gcd-test-dataset-directory/ &
fi

if [ $STEP_NAME = '7-compute-engine' ]; then
  # replace all @@'s with placeholders, since this breaks yaml parsing
  sed -i -e 's/@//g' $TEST_DIR/config/database.yml $TEST_DIR/config/settings.yml
fi

# run rake DB tasks after all other changes
if [ -d $TEST_DIR/db/migrate ]; then
  # create the tables required for testing
  RAILS_ENV=test rake --rakefile=$TEST_DIR/Rakefile db:migrate
fi
