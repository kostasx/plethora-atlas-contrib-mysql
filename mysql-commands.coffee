colors = require 'colors'

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

        Helpers.configurator().then((res)->

          database = require './mysql'
          database.init({

            host     : config.mysql.host
            user     : config.mysql.user
            password : config.mysql.password

          })

          # CREATE DATABASE 
          if options.createDb

            console.log "Creating Database #{options.createDb}..."
            database.databaseExists({ dbname: options.createDb })
            .then(database.createDatabase.bind(null, { dbname: options.createDb }))
            .then( (res)-> console.log res )

          # DROP DATABASE 
          if options.dropDb or options.rmDb or options.delDb

            console.log "Removing Database #{options.dropDb}..."
            database.dropDatabase({ dbname: options.dropDb })
            .then( (res)-> console.log res )

          # SHOW DATABASES
          if options.showDb

            console.log "Getting Databases..."
            database.getDatabases()
            .then( (res)-> console.log res )
            .catch( (e)-> console.log e )

          # DUMP DATABASE
          if options.dumpDb

            console.log "Dumping Database #{options.dumpDb}..."
            database.mySqlDump({ 

              dbname        : options.dumpDb
              mysqldump_bin : config.database.mysqldump_bin 
              write         : true

            })
            .then( (res)-> console.log res )
            .catch( (e)-> console.log e )

        ).catch(console.log)

module.exports = initCommands