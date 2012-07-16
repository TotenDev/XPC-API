TDevShortener
=============

TDevShortener has been developed by TotenDev team, as an internal system with the main principle of been a private and simple shortener for anyone who wants it.

[![Build Status](https://secure.travis-ci.org/TotenDev/TDevShortener.png?branch=master)](http://travis-ci.org/TotenDev/TDevShortener)

##Requirements

- [npm](https://github.com/isaacs/npm)
- [nodejs](https://github.com/joyent/node) **(and some dependencies)**
- mysql server connection
- [TDevMetrics](https://github.com/TotenDev/TDMetrics/) **OPTIONAL**

##Installing

All Stable code will be on `master` branch, any other branch is designated to unstable codes. So if you are installing for production environment, use `master` branch for better experience.

To run TDevShortener you MUST have mysql server connection and [database configured](https://github.com/TotenDev/TDevShortener/raw/master/application/db.sql). All credentials and preferences can be configured at `package.json` and are described [here](#configuration).

---

After configured your environment you can run commands below to start TDevShortener:

Initialize **GIT** submodules

	$ git submodule init
	$ git submodule update

Download and install dependencies

	$ npm install

Start server
	
	$ 'node main.js' OR 'foreman start'

##Configuration

All Configuration can be done through `package.json` file in root directory.

#### Database Config
Database is used for storing all shortened URL and Codes.
- `database.host` - MySQL Host. **REQUIRED**
- `database.port` - MySQL Host Port. **REQUIRED**
- `database.user` - MySQL DB User. **REQUIRED**
- `database.password` - MySQL DB Password. **REQUIRED**
- `database.database` - MySQL DB Name. **REQUIRED**
- `database.table` - MySQL DB Table Name. **REQUIRED**

---
#### REST Config
REST is used for all `HTTP` talks. 
- `rest.host` - REST Listening Host. **REQUIRED**
- `rest.port` - REST Listening Port. **REQUIRED**
- `rest.cache-state` - REST Cache State (1-ON 0-OFF), it'll cache last 1000 URLs and Codes. **REQUIRED**
- `rest.cache-expires` - REST Cache expires, in milliseconds. **REQUIRED IF rest.cache-state is ON**

---
#### METRICS Config
All Metrics configuration should be done in `application/TDMetrics/package.json` file, if you do not have this file, please initialize **GIT** submodules.

Please read [here](https://github.com/TotenDev/TDMetrics-LibNode#configuration) for more details.

##Rest API

####Short URL (POST)
- Method: `POST`
- URL: `example.com/create/`
- Body: `http://mylongurl.sobig.com/tolong`
- Success codes: 
	- `200` - `http://sh.tt/12345678`
- Error Codes: 
	- `202`
	- `409`
	- `500`
	
---
####Short URL (GET)
- Method: `GET`
- URL: `example.com/create/http://mylongurl.sobig.com/tolong`
- Success codes: 
	- `200` - `http://sh.tt/12345678`
- Error Codes: 
	- `202`
	- `409`
	- `500`
	
---
####Solve URL
- Method: `GET`
- URL: `example.com/12345678/`
- Success codes: 
	- `302`
- Error Codes: 
	- `202`
	- `409`
	- `500`

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
	
##License
[GPLv3](TDevShortener/raw/master/LICENSE)