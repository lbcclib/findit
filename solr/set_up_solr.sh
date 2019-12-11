wget https://www-us.apache.org/dist/lucene/solr/8.3.1/solr-8.3.1.tgz
tar xzvf solr-8.3.1.tgz
cp schema.xml solr-8.3.1/example/files/conf/schema.xml
solr-8.3.1/bin/solr start
solr-8.3.1/bin/solr create_core -c blacklight-core -d solr-8.3.1/example/files/conf/
git checkout https://github.com/sandbergja/findit_data_tools
