# exporting marts into csv to import them into Looker Studio as HEX analytics is not for free

import duckdb
import os

os.makedirs("exports", exist_ok=True)

con = duckdb.connect("retail.duckdb", read_only=True)

con.execute("COPY dbt_retail.mart_market_performance TO 'exports/mart_market_performance.csv' (HEADER, DELIMITER ',')")
con.execute("COPY dbt_retail.mart_merchandising_mix TO 'exports/mart_merchandising_mix.csv' (HEADER, DELIMITER ',')")
con.execute("COPY dbt_retail.mart_product_attributes_performance TO 'exports/mart_product_attributes_performance.csv' (HEADER, DELIMITER ',')")

con.close()
print("Exported all marts to exports/")
