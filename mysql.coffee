mysql  = require 'mysql'
colors = require 'colors'

db = 

	connect: (options)->

		return mysql.createConnection
			host     : options.host
			user     : options.user
			password : options.password

	databaseExists: (options)->

		new Promise((resolve,reject)->

			connection = db.connect({ host: options.host, user: options.user, password: options.password })
			connection.query "USE #{options.dbname}", (err, rows, fields) ->

				if err
					return resolve({ msg: "Database #{options.dbname} does not exist", exists: false }) 
				else
					return reject({ msg: "Warning: Database #{options.dbname} exists. Remove before continuing.\n", exists: true }) 

			connection.end()

		)

	createDatabase: (options) ->

		new Promise((resolve,reject)->

			connection = db.connect({ host: options.host, user: options.user, password: options.password })
			connection.query 'create database `' + options.dbname + '`', (err, rows, fields) ->
				if err
					console.log "Error: createDatabase - #{err}".red
					return reject({ msg: "createDatabase - Error", error: err, dname: options.dbname }) 
				else
					Helpers.notify('Database created succesfully!')
					return resolve({ msg: "Database created succesfully!", dbname: options.dbname })

			connection.end()

		)

	execQuery: (options)->

		new Promise((resolve,reject)->

			connection = db.connect({ host: options.host, user: options.user, password: options.password })
			connection.query( options.query, (err, rows, fields)->
				if err 
					return resolve({ msg: "Error executing query: #{options.query}" })
				else
					return resolve({ msg: "Query #{options.query} executed succesfully!", rows: rows, fields: fields })
			)

			connection.end()

		)

	dropDatabase: (options) ->

		new Promise((resolve,reject)->

			connection = db.connect({ host: options.host, user: options.user, password: options.password })
			connection.query 'drop database `' + options.dbname + '`', (err, rows, fields) ->
				if err
					console.log "Error: dropDatabase - #{err}".red
					return resolve({ msg: "dropDatabase - Error", error: err }) 
				else
					return resolve({ msg: "Database #{options.dbname} was removed." })

			connection.end()

		)

	getDatabases: (options)->
	
		databases = []

		new Promise((resolve,reject)->
	
			connection = db.connect({ host: options.host, user: options.user, password: options.password })
			connection.query 'show databases', (err, rows, fields) ->

				if err then return reject({ msg: "Error", error: err })

				rows.forEach (db) ->
					if db.Database != 'mysql' and db.Database != 'information_schema' and db.Database != 'performance_schema'
						databases.push db.Database

				return resolve({ msg: "", databases: databases })
	
			connection.end()
		)

	sanitizeDBNameSync: (dbname)->

		return dbname
		.replace( /\./g, "_" )
		.replace( /-/g,  "_" )
		.replace( / /g,  "_" )
		.replace( /\//g, ""  )

	# Also see: https://github.com/webcaetano/mysqldump
	mySqlDump: (options)->

		new Promise((resolve, reject)->

			exec      = require('child_process').exec
			mysqldump = options.mysqldump_bin
			sqluser   = options.user
			sqlpass   = options.password
			dbname    = options.dbname
			cmd       = mysqldump + ' -u' + sqluser + ' -p' + sqlpass + ' ' + dbname

			if options.write
				cmd = "#{cmd} > #{dbname}.sql"

			db.databaseExists({ dbname: dbname, host: options.host, user: options.user, password: options.password })
			.then((res)-> 

				# res.exists === false  
				reject("ERROR: Database #{dbname} does not exist".red)
			
			)
			.catch((e)-> 
				
				child = exec cmd, (err, stdout, stderr) ->
				  if err != null 
				  	console.log stderr.red, err
				  	reject("ERROR: Problem exporting #{dbname} database.".red)
				  else
					console.log stdout
					resolve("#{dbname} dumped successfully.")

			)

		)

module.exports = db