colors = require 'colors'

dbConfig =
  host     : config.database.host
  user     : config.database.user
  password : config.database.password

initCommands = (program)->

    program
      .command('mysql')
      .description('MySQL Database related utilities')
      .option('--create-db <dbname>','Create a MySQL Database')
      .option('--drop-db <dbname>','Drop a MySQL Database.')
      .option('--rm-db <dbname>','Alias for --drop-db')
      .option('--del-db <dbname>','Alias for --drop-db')
      .option('--show-db','Show current MySQL Databases')
      .option('--dump-db <dbname>','Dump selected MySQL Database')
      .action (options) ->

        # CREATE DATABASE 
        if options.createDb

          console.log "Creating Database #{options.createDb}..."
          database = require './mysql'
          database.databaseExists({ 

            dbname   : options.createDb
            host     : dbConfig.host
            user     : dbConfig.user
            password : dbConfig.password 

          })
          .then(database.createDatabase.bind(null, { 

            dbname   : options.createDb 
            host     : dbConfig.host
            user     : dbConfig.user
            password : dbConfig.password

          }))
          .then( (res)-> console.log res )

        # DROP DATABASE 
        if options.dropDb or options.rmDb or options.delDb

          console.log "Removing Database #{options.dropDb}..."
          database = require './mysql'
          database.dropDatabase({ 

            host     : dbConfig.host
            user     : dbConfig.user
            password : dbConfig.password
            dbname   : options.dropDb 

          })
          .then( (res)-> console.log res )

        # SHOW DATABASES
        if options.showDb

          console.log "Getting Databases..."
          database = require './mysql'
          database.getDatabases({

            host     : dbConfig.host
            user     : dbConfig.user
            password : dbConfig.password

          })
          .then( (res)-> console.log res )
          .catch( (e)-> console.log e )

        # DUMP DATABASE
        if options.dumpDb

          console.log "Dumping Database #{options.dumpDb}..."
          database = require './mysql'
          database.mySqlDump({ 

            dbname        : options.dumpDb
            mysqldump_bin : config.database.mysqldump_bin 
            host          : dbConfig.host
            user          : dbConfig.user
            password      : dbConfig.password
            write         : true

          })
          .then( (res)-> console.log res )
          .catch( (e)-> console.log e )

module.exports = initCommands