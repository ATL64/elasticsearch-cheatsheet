#I have used these in elasticsearch v6

#Delete several indices:

curl -X DELETE "{protocol}://{host}:{port}/{index_prefix}.{09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28}"


#Clear your cached search scroll, in case your job does several searches

curl -X DELETE "{protocol}://{host}:{port}/_search/scroll/_all"


#Clear cache from cluster, helpful if you loaded too much data and cluster becomes unresponsive.
#If still unresponsive after that, restarting all nodes and proceeding to delete indices should work.

curl -X POST "{protocol}://{host}:{port}/_all/_cache/clear"

#Put path of snapshots if restoring them into your cluster:

curl -X PUT \
  {protocol}://{host}:{port}/_snapshot/gcs \
  -H 'Accept: */*' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Host: {protocol}://{host}:{port}' \
  -H 'accept-encoding: gzip, deflate' \
  -H 'cache-control: no-cache' \
  -d '{
    "type": "gcs",
    "settings": {
        "bucket": "your_gcs_bucket",
        "max_restore_bytes_per_sec": "1gb",
        "compress": "true",
        "client": "snapshot",
        "http": {
            "connect_timeout": "1m",
            "read_timeout": "1m"
        },
        "base_path": "your_path/your_logs",
        "max_snapshot_bytes_per_sec": "100mb"
    }
}'



# REINDEX

# Reindexing data, particularly to keep only a subset of interest.  
# Not a trivial problem if data is large (dozens of hundreds of TB)

# 1. First create the empty index

curl -X PUT "{protocol}://{host}:{port}/{index}"

# 2. Increase total_fields if your data has this kind of complexity

curl -X PUT "{protocol}://{host}:{port}/{index}/_settings" -H 'Content-Type: application/json' -d'
{
"index.mapping.total_fields.limit" : 20000
}
'

# 3. Put your mapping to the index, otherwise you can't put data in it.

curl -X PUT "{protocol}://{host}:{port}/{index}/_mapping/_doc 
{
  "properties": {
    "email": {
      "type": "keyword"
    }
  }
}

# 3.b. Another option for huge mappings is to use elasticdump to copy the mapping, and then again use elasticdump to copy the data.
# Beware of the speed, it will be very slow if it's running outside the cluster itself.

# 4. Use a query to filter during the reindex:

curl -X POST "{protocol}://{host}:{port}/_reindex" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "{index}",
    "query": {
            {
              "exists": {
                "field": "search_id"
              }
            }
    }
  },
  "dest": {
    "index": "{new_index_name}"
  }
}
'
