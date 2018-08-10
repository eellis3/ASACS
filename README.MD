The Atlanta Sharing Alliance Coordination System (ASACS) allows various providers of shelter,
clothing and housing to coordinate their activities, reserve resources, report availability of
bunks/rooms/food and request items from food banks. This database system allows users who work at
soup kitchens, food pantries, food banks and shelters to more effectively provide service to clients, see
available donations stored at food banks and make requests for them. In addition, it provides real-time
reports on the total capacity of the Atlanta Sharing Alliance which can be used for planning and fundraising
purposes. It also allows unauthenticated clients with access to a web capable device to pull up
real-time reports on available beds or meals.

See Project Details PDF for more info.

DB login
Username:  root
Password:  rootroot

SQL is located:
ASACS_app\sql\team092_p3_complete.sql
Main Code:
ACACS_app\ASACS_app.py
HTML files:
ACACS_app\templates\

To run the app:
Python v2.7
pip install flask
pip install flask-mysql
pip install pygal

Then chang user, password, and port if needed.
app.config['MYSQL_DATABASE_USER'] = 'root'
## add your password you created when you installed Bitnami WAMP
app.config['MYSQL_DATABASE_PASSWORD'] = 'admin'
app.config['MYSQL_DATABASE_DB'] = 'cs6400_sp17_team092'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
app.config['MYSQL_DATABASE_PORT'] = 8080

Good Websites:
http://flask.pocoo.org/docs/0.12/
https://code.tutsplus.com/tutorials/creating-a-web-app-from-scratch-using-python-flask-and-mysql--cms-22972
http://codehandbook.org/python-web-application-flask-mysql/
http://codehandbook.org/restful-api-using-python-flask-mysql-part-2/
https://scotch.io/tutorials/build-a-crud-web-app-with-python-and-flask-part-one
http://www.tutorialspoint.com/flask/
