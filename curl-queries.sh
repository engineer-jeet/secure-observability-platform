# List indices
curl -k -u admin:<password> https://localhost:9200/_cat/indices?v

# Search traces index
curl -k -u admin:<password> https://localhost:9200/traces-payment/_search?pretty