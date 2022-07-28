--Query to get Instance Version details

SELECT product,
       version,
       status
FROM   product_component_version;  

--Query to  get cloned date of an oracle instance

SELECT resetlogs_time
FROM   v$database; 

--Query to get the front end URL from back-end

SELECT home_url
FROM   icx_parameters;   