#!/bin/bash
SOLR_VERSION=8.4.0
rm -rf solr-$SOLR_VERSION*
wget http://apache.osuosl.org/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz
tar xzvf solr-$SOLR_VERSION.tgz
cp schema.xml solr-$SOLR_VERSION/example/files/conf/schema.xml
solr-$SOLR_VERSION/bin/solr start
solr-$SOLR_VERSION/bin/solr create_core -c blacklight-core -d solr-$SOLR_VERSION/example/files/conf/
git clone https://github.com/lbcclib/findit_data_tools
cd findit_data_tools
ruby findit_data.rb -i eg ../eg.mrc 
cd -
