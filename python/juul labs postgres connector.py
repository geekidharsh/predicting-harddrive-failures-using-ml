# @author: Harshvardhan Pandey

import psycopg2
import pandas as pd


# db connection object generator
def postgres_db_connection(): # postgresql://35.230.114.237", "postgres", "luuj"
	try:
		conn = psycopg2.connect(host="35.230.114.237", dbname="postgres", 
		user="candidate", password="luuj")
		print('Connecting to postgresql server...')
		cur = conn.cursor()
		print('Successfully connected to the host\n')
	except:
		print('\nConnection to pgsql unsuccessful')

	return cur



def get_all_tables(cur):
	print('Extracting list of tables:')
	cur.execute("SELECT * FROM pg_catalog.pg_tables where schemaname NOT IN ('pg_catalog', 'information_schema')")
	tables = cur.fetchall()
	t = [i[1] for i in tables]
	return t


def lookup_a_table(cur, tablename):
	# get data from a given table: tablename
	print("\nReading table: "+tablename+"...")
    # cur.execute('SELECT * from '+tablename+' limit 10')

	# get table_data
	cur.execute("SELECT count(*) from "+tablename)
	table_rows = cur.fetchall()
	print("Number of rows in table: {} are {}".format(tablename, table_rows))
	cur.execute("SELECT * from "+tablename)
	table_data = cur.fetchall()
	return table_data


def get_table_columns(cur, tablename):

	# get column_names
	print('Fetching columns in: ', tablename)
	try: 
		cur.execute("SELECT table_name, column_name from information_schema.columns where table_name = '"+tablename+"'")
		column_names = cur.fetchall()
		column_names = [j[1] for j in column_names]
		print(column_names)
	except:
		print('Column fetch failed')

	return column_names 


# ETL utility functions
# ---------------------

# transform data in pandas
def clean_response(table, data, column_names):
	# inp: table data and column_names
	# out: pandas dataframe

	data = pd.DataFrame(data)
	data.columns = [column_names]
	print(data.head())
	out_file = 'out_data_from_tablename_'+table+'.csv'
	print('Saving data from table: {}, to file: {}'.format(table, out_file))
	data.to_csv(out_file, index=False, encoding='utf-8')
	print('Done.')

db_conn_obj = postgres_db_connection()	
tables = get_all_tables(db_conn_obj)
table = 'hard_drive_stats'
data = lookup_a_table(db_conn_obj, table)
columns = get_table_columns(db_conn_obj, table)

clean_response(table, data, columns)


