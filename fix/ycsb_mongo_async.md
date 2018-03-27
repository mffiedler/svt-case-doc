# YCSB

# YCSB for mongo-async

[YCSB/issues/996](https://github.com/brianfrankcooper/YCSB/issues/996)

```sh
# oc new-project ttt
# oc new-app --template=mongodb-persistent -p MONGODB_ADMIN_PASSWORD=cool -p MEMORY_LIMIT=4096Mi -p MONGODB_USER=redhat -p MONGODB_PASSWORD=redhat -p MONGODB_DATABASE=testdb -p VOLUME_CAPACITY=100Gi

# oc rsh mongodb-1-tbddb
sh-4.2$ mongo -u admin -p cool 127.0.0.1:27017/admin
MongoDB shell version: 3.2.10
connecting to: 127.0.0.1:27017/admin
...
> db.system.users.findOne({user: "***"})
{
	"_id" : "testdb.***",
	"user" : "***",
	"db" : "testdb",
	"credentials" : {
		"SCRAM-SHA-1" : {
			"iterationCount" : 10000,
			"salt" : "***",
			"storedKey" : "***",
			"serverKey" : "***"
		}
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "testdb"
		}
	]
}

```

Mongodb [auth mechanisms](https://docs.mongodb.com/manual/release-notes/3.0-scram/) and [how to check](https://www.mongodb.com/blog/post/improved-password-based-authentication-mongodb-30-scram-explained-part-2?jmp=docs&_ga=2.259405834.1612212702.1522154273-637184529.1521748721).
