from flask import Flask, render_template, request, session, flash, redirect
from flaskext.mysql import MySQL
import pygal
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

app = Flask(__name__)
app.secret_key ='l?\xa1\xa6qS\xf9\x01\xa3+3\x06]\xb2ol\xd6\xa7\xdc\xae\xe8\x06Q\x01'
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
## add your password you created when you installed Bitnami WAMP
app.config['MYSQL_DATABASE_PASSWORD'] = 'rootroot'
app.config['MYSQL_DATABASE_DB'] = 'cs6400_sp17_team092'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
# app.config['MYSQL_DATABASE_PORT'] = 8080
mysql.init_app(app)

### this returns one line of sql
def fetchone(sqlStatement):
    cursor = mysql.get_db().cursor()
    cursor.execute(sqlStatement)
    results = cursor.fetchone()
    cursor.close()
    return results
### this returns everything requested from sql statement
def fetchall(sqlStatement):
    cursor = mysql.get_db().cursor()
    cursor.execute(sqlStatement)
    results = cursor.fetchall()
    cursor.close()
    return results

def insertSQL(sqlStatement):
    con = mysql.connect()
    cursor = con.cursor()
    cursor.execute(sqlStatement)
    data = cursor.fetchall()
    if len(data) is 0:
        con.commit()
        cursor.close()
        return True
    else:
        return False

### input a service table and returns a list of dictionaries with name, service id, and site id
def getSiteNameAndServiceID(serviceName):
    ### serviceName = FoodBank, FoodPantry, Shelter, or SoupKitchen
    ### example: getSiteNameAndServiceID('FoodBank')
    sqlSiteNames = "SELECT sitename, Service.serviceid, Site.siteid FROM Site INNER JOIN Service ON Site.siteid = Service.siteid " \
                   "INNER JOIN " + serviceName + " ON Service.serviceid=" + serviceName + ".serviceid"
    siteNames = fetchall(sqlSiteNames)
    siteNamesList = []
    for x in siteNames:
        i = {
            'siteName': x[0],
            'serviceID': x[1],
            'siteID': x[2]
        }
        siteNamesList.append(i)
    return siteNamesList

def getAvailability():
    available = {}

    sqlStatement = "(SELECT * FROM Foodbank WHERE Foodbank.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
    available["foodBank"] = 'false' if fetchone(sqlStatement) != None else 'true'
    sqlStatement = "(SELECT * FROM FoodPantry WHERE FoodPantry.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
    available["foodPantry"] = 'false' if fetchone(sqlStatement) != None else 'true'
    sqlStatement = "(SELECT * FROM Shelter WHERE Shelter.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
    available["shelter"] = 'false' if fetchone(sqlStatement) != None else 'true'
    sqlStatement = "(SELECT * FROM SoupKitchen WHERE SoupKitchen.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
    available["soupKitchen"] = 'false' if fetchone(sqlStatement) != None else 'true'
    return available

def getRequests():
    sqlGetRequestsForUser = "SELECT R.requestid, R.serviceidapproving, R.itemid, R.unitsrequested, R.unitsapproved, I.name, I.expdate, I.units, S.sitename, " \
                            "CASE " \
                            "WHEN R.unitsapproved IS Null THEN 'Pending' " \
                            "WHEN R.unitsapproved=0  THEN 'Denied' " \
                            "WHEN R.unitsapproved < R.unitsrequested THEN 'Partial' " \
                            "WHEN R.unitsapproved=R.unitsrequested THEN 'Full'" \
                            "ELSE 'Unknown' " \
                            "END AS statusReq " \
                            "FROM ItemRequests AS R INNER JOIN Items AS I INNER JOIN Site AS S  INNER JOIN Service AS X " \
                            "WHERE R.itemid=I.itemid AND R.username='%s' AND R.serviceidapproving=X.serviceid AND X.siteid=S.siteid" % session['username']
    requestResults = fetchall(sqlGetRequestsForUser)
    results = []
    for x in requestResults:
        i = {
            'requestID': x[0],
            'serviceIDapproving': x[1],
            'itemID': x[2],
            'unitsReq': x[3],
            'unitsApp': x[4],
            'nameDesc': x[5],
            'expDate': x[6],
            'units': x[7],
            'siteName': x[8],
            'status': x[9]
        }
        results.append(i)
    return results
def bedExists():
    selectBedsExist = "SELECT IFNULL(SUM(IFNULL(Bunks.maleavailable, 0) +  " \
                      "IFNULL(Bunks.femaleavailable, 0) +  " \
                      "IFNULL(Bunks.mixavailable, 0) +  " \
                      "IFNULL(FamilyRoom.available, 0)), 0) AS sumAll " \
                      "FROM Shelter " \
                      "INNER JOIN Bunks ON Bunks.serviceid = Shelter.serviceid " \
                      "INNER JOIN FamilyRoom ON FamilyRoom.serviceid = Shelter.serviceid " \
                      "ORDER BY sumAll DESC " \
                      "LIMIT 1; "

    bedResults=  fetchall(selectBedsExist)
    return bedResults[0][0]

def checkForLastService():
    sqlCountServices = "SELECT count(siteid) FROM Service WHERE siteid=%s" % session['siteid']
    returnCount = fetchone(sqlCountServices)
    if returnCount[0] == 1:
        return True
    else:
        return False

def getItemRequestedBarChart():
    items_sql = """
                Select SUM(ir.unitsrequested - ir.unitsapproved) as totalMissed, i.name
                from ItemRequests AS ir
                LEFT JOIN items as i
                ON ir.itemid = i.itemid
                where ir.unitsapproved IS NOT NULL
                group by serviceidapproving, ir.itemid
                having totalMissed > 0
                order by totalMissed desc, serviceidapproving, ir.itemid
            """
    needed_items = fetchall(items_sql)

    bar_chart = pygal.Bar()
    bar_chart.title = 'Most Requested Items'
    bar_chart.x_labels = [needed_items[x][1] for x in range(len(needed_items))]
    bar_chart.add("No. Needed", [needed_items[x][0] for x in range(len(needed_items))])
    return bar_chart

@app.route('/')
def main():
    if 'username' in session:
        return redirect('/mainmenu')
    else:
        return redirect('/login')

@app.route('/login')
def showLogin():
    return render_template('login.html', bedsExist=bedExists())

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        inputUsername = request.form['inputUsername']
        inputPassword = request.form['inputPassword']
        sqlLogin = "SELECT firstName, lastName, siteid FROM Users WHERE username='" + inputUsername + "'AND password='" + inputPassword + "'"
        results = fetchone(sqlLogin)
        if results is None:
            error = 'Incorrect Login'
            return render_template('login.html', bedsExist=bedExists(), error=error)
        else:
            ### you can pull session variables in any page
            session['username'] = inputUsername
            session['firstname'] = results[0]
            session['lastname'] = results[1]
            session['siteid'] = results[2]
            sqlSiteName = "SELECT sitename FROM Site WHERE siteid=%s" % session['siteid']
            siteName = fetchone(sqlSiteName)
            session['sitename'] = siteName[0]

            return redirect('/mainmenu')
    else:
        redirect('/login')

@app.route('/logout')
def logout():
    session.pop('username',None)
    session.pop('firstname', None)
    session.pop('lastname', None)
    session.pop('siteid', None)
    session.pop('sitename', None)
    return redirect('/')


@app.route('/mainmenu')
def showMainMenu():
    if 'username' in session:
        sqlSite ="SELECT * FROM Site WHERE siteid='" + str(session['siteid']) + "'"
        results = fetchone(sqlSite)
        return render_template('mainmenu.html', firstname=session['firstname'], lastname=session['lastname'], phone=results[2],
                               address1=results[3], address2=results[4], sitename=results[1], city=results[5], state=results[6],
                               zip=results[7])
    else:
        return redirect('/login')

## completed
@app.route('/itemSearchReport')
def showItemSearchReport():
    if 'username' in session:
        siteNamesList = getSiteNameAndServiceID('FoodBank')

        return render_template('itemSearchReport.html', siteNames=siteNamesList, session=session, bar_chart = getItemRequestedBarChart())
    else:
        return redirect('/login')

## completed
@app.route('/itemSearchReport', methods=['GET', 'POST'])
def itemSearch():
    ### throws notification on page of errors or successes
    error = None
    successLog = None

    if request.method == 'POST':
        siteNamesList = getSiteNameAndServiceID('FoodBank')
        if request.form['button'] == 'searchButton':
            itemID = request.form['itemID']
            nameDesc = request.form['nameDesc']
            expDate = request.form['expDate']
            storageType = request.form['storageType']
            foodSupply = request.form['foodSupply']
            category = request.form['category']
            serviceID = request.form['serviceID']
            notServiceID = request.form['notServiceID']
            showExpired = request.form['showExpired']
            firstFlag = True
            if itemID == '' and nameDesc =='' and expDate =='' and storageType=='' and foodSupply=='' and category=='' and serviceID=='' and notServiceID=='' and showExpired=='':
                sqlItemSearch = "SELECT * FROM Items INNER JOIN ItemType ON Items.itemtypeid = ItemType.itemtypeid"
            else:
                sqlItemSearch = "SELECT * FROM Items INNER JOIN ItemType ON Items.itemtypeid = ItemType.itemtypeid WHERE "
                if itemID != '':
                    if firstFlag:
                        sqlItemSearch += "Items.itemid='" + str(itemID) + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND Items.itemid='" + str(itemID) + "'"
                if nameDesc !='':
                    nameDesc = '%' + nameDesc + '%'
                    if firstFlag:
                        sqlItemSearch += "Items.name LIKE '" + nameDesc + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND Items.name LIKE '" + nameDesc + "'"
                if expDate !='':
                    if firstFlag:
                        sqlItemSearch += "Items.expdate ='" + expDate + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND Items.expdate='" + expDate + "'"
                if storageType !='':
                    if firstFlag:
                        sqlItemSearch += "Items.storagetype ='" + storageType + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND Items.storagetype ='" + storageType + "'"
                if foodSupply != '':
                    if foodSupply == 'Food':
                        foodSupply = '1'
                    else:
                        foodSupply = '0'
                    if firstFlag:
                        sqlItemSearch += "ItemType.isFood ='" + foodSupply + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND ItemType.isFood ='" + foodSupply + "'"
                if category != '':
                    if firstFlag:
                        sqlItemSearch += "ItemType.typename ='" + category + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND ItemType.typename ='" + category + "'"
                if serviceID != '':
                    if firstFlag:
                        sqlItemSearch += "Items.serviceid='" + serviceID + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND Items.serviceid='" + serviceID + "'"
                if notServiceID != '':
                    if firstFlag:
                        sqlItemSearch += "NOT Items.serviceid='" + notServiceID + "'"
                        firstFlag = False
                    else:
                        sqlItemSearch += " AND NOT Items.serviceid='" + notServiceID + "'"
                if showExpired != '':
                    if firstFlag:
                        if showExpired == 'Yes':
                            sqlItemSearch += "expdate<CURDATE()"
                        else:
                            sqlItemSearch += "expdate>=CURDATE()"
                        firstFlag = False
                    else:
                        if showExpired == 'Yes':
                            sqlItemSearch += " AND expdate<CURDATE()"
                        else:
                            sqlItemSearch += " AND expdate>=CURDATE()"
            results = fetchall(sqlItemSearch)
            items_list =[]
            for item in results:
                ### display Food or Supply instead of 0 or 1 and category = typename item[6] = itemtypeID
                sqlGetItemType = "SELECT typename, isFood FROM ItemType WHERE itemtypeid='" + str(item[6]) + "'"
                itemTypeResult = fetchone(sqlGetItemType)
                if itemTypeResult[1] == 0:
                    foodOrSupply = 'Supply'
                else:
                    foodOrSupply = 'Food'

                ### display Site Name instead of Service ID.  item[5] = service ID
                sqlGetSiteName = "SELECT sitename FROM Site INNER JOIN Service ON Site.siteid = Service.siteid WHERE " \
                                 "Service.serviceid='" + str(item[5]) + "'"
                siteNameResult = fetchone(sqlGetSiteName)

                i ={
                    'itemID':item[0],
                    'nameDesc':item[1],
                    'expDate':item[2],
                    'units':item[3],
                    'storageType':item[4],
                    'siteName':siteNameResult[0],
                    'category':itemTypeResult[0],
                    'foodSupply':foodOrSupply
                }
                items_list.append(i)

            return render_template('itemSearchReport.html', results=items_list, siteNames=siteNamesList, session=session, bar_chart = getItemRequestedBarChart())

        ### REQUEST ITEM
        elif request.form['button'] == 'requestButton':
            itemID = request.form['itemID']
            units = request.form['units']
            username = session['username']
            usersSiteID = session['siteid']
            if not itemID or not units:
                error = 'ENTER IN A VALUE'
            else:
                sqlGetServiceID = "SELECT serviceid, units FROM Items WHERE itemid='" + itemID + "'"
                resultServiceID = fetchone(sqlGetServiceID)
                sqlGetUsersServiceID = "SELECT FoodBank.serviceid FROM FoodBank INNER JOIN Service ON FoodBank.serviceid=Service.serviceid " \
                                       "INNER JOIN Site ON Site.siteid=Service.siteid WHERE Site.siteid='" + str(usersSiteID) + "'"
                resultUserServiceID = fetchone(sqlGetUsersServiceID)
                sqlGetRequestID = "SELECT requestid FROM ItemRequests WHERE itemid=%s AND username='%s' AND serviceidapproving=%s" % (itemID, username, resultServiceID[0])
                resultRequestID = fetchone(sqlGetRequestID)

                if not resultUserServiceID:
                    resultUserServiceID = [0]
                if int(resultServiceID[1]) < int(units):
                    error = 'TOO MANY UNITS REQUESTED'
                elif int(units) <= 0:
                    error = 'CANNOT REQUEST 0 ITEMS'
                elif int(resultServiceID[0]) == int(resultUserServiceID[0]):
                    error = "CAN'T REQUEST ITEM FROM YOUR OWN SITE"
                elif resultRequestID:
                    error = "CAN'T REQUEST SAME ITEM.  GO TO ITEM REQUEST STATUS REPORT TO EDIT REQUEST"
                else:
                    sqlRequestItem = "INSERT INTO ItemRequests(serviceidapproving, username, itemid , unitsrequested) VALUES " \
                                     "(" + str(resultServiceID[0]) + ",'" + username + "'," + itemID +"," + units + ")"
                    successInsert = insertSQL(sqlRequestItem)
                    if successInsert:
                        successLog = "Successful Request"
                    else:
                        error = "Unable to request item"
            return render_template('itemSearchReport.html', error=error, siteNames=siteNamesList, successLog=successLog, session=session, bar_chart = getItemRequestedBarChart())

        ### EDIT ITEM IN USERS OWN SITE
        elif request.form['button'] == 'editButton':
            itemID = request.form['itemID']
            units = request.form['units']
            usersSiteID = session['siteid']
            if not itemID or not units:
                error = 'ENTER IN A VALUE'
            else:
                sqlGetServiceID = "SELECT serviceid, units FROM Items WHERE itemid='" + itemID + "'"
                resultServiceID = fetchone(sqlGetServiceID)
                sqlGetUsersServiceID = "SELECT FoodBank.serviceid FROM FoodBank INNER JOIN Service ON FoodBank.serviceid=Service.serviceid " \
                                       "INNER JOIN Site ON Site.siteid=Service.siteid WHERE Site.siteid='" + str(usersSiteID) + "'"
                resultUserServiceID = fetchone(sqlGetUsersServiceID)
                if not resultUserServiceID:
                    resultUserServiceID = [0]
                if int(resultServiceID[0]) != int(resultUserServiceID[0]):
                    error = "CAN'T EDIT AN ITEM NOT AT YOUR SITE"
                else:
                    sqlEditItem = "UPDATE Items SET Items.units=%s WHERE itemid=%s" % (units, itemID)
                    successEdit = insertSQL(sqlEditItem)
                    if successEdit:
                        successLog = "Successful Edit"
                    else:
                        error = "Unable to edit item"

            return render_template('itemSearchReport.html', error=error, siteNames=siteNamesList, successLog=successLog, session=session, bar_chart = getItemRequestedBarChart())
        else:
            return redirect('/mainmenu')
    else:
        return redirect('/itemSearchReport')

@app.route('/viewServices')
def showServices():
    if 'username' in session:
        return render_template('viewServices.html', available=getAvailability())
    else:
        return redirect('/login')


@app.route('/addService', methods=['GET', 'POST'])
def showAddServices():
    if 'username' in session:
        if request.method == "POST":
            newserviceid=0
            sqlStatement = "INSERT INTO Service (siteid) VALUES(%s)" %(str(session["siteid"]))
            insertSQL(sqlStatement)
            newserviceid = str(fetchone("SELECT MAX(Service.serviceid) FROM Service")[0])
            if request.form['button'] == 'soupKitchen':
                sqlStatement = "INSERT INTO SoupKitchen (serviceid, description, seat) VALUES(%s, '%s', %s)" % (newserviceid, request.form['description'], request.form['seats'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO HoursOfOperation (serviceid, open, closed, day) VALUES(%s, '%s', '%s', '%s')" %(newserviceid, request.form['open'], request.form['closed'], request.form['day'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO Conditions (serviceid, conditions) VALUES (%s, '%s');" % (newserviceid, request.form['conditions'])
                insertSQL(sqlStatement)
            elif request.form['button'] == 'foodBank':
                sqlStatement = "INSERT INTO FoodBank (serviceid) VALUES(%s)" % (newserviceid)
                insertSQL(sqlStatement)
            elif request.form['button'] == 'foodPantry':
                sqlStatement = "INSERT INTO FoodPantry (serviceid, description) VALUES(%s, '%s')" % (newserviceid, request.form['description1'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO HoursOfOperation (serviceid, open, closed, day) VALUES(%s, '%s', '%s', '%s')" %(newserviceid, request.form['open1'], request.form['closed1'], request.form['day1'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO Conditions (serviceid, conditions) VALUES (%s, '%s');" % (newserviceid, request.form['conditions1'])
                insertSQL(sqlStatement)
            elif request.form['button'] == 'shelter':
                sqlStatement = "INSERT INTO Shelter (serviceid, description) VALUES(%s, '%s')" % (newserviceid, request.form['description2'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO HoursOfOperation (serviceid, open, closed, day) VALUES(%s, '%s', '%s', '%s')" %(newserviceid, request.form['open2'], request.form['closed2'], request.form['day2'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO Bunks (serviceid, maleavailable, femaleavailable, mixavailable, malemax, femalemax, mixmax) VALUES(%s, %s, %s, %s,%s, %s, %s)" % (newserviceid, request.form['mBunks'], request.form['fBunks'], request.form['mixBunks'], request.form['mBunks'], request.form['fBunks'], request.form['mixBunks'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO FamilyRoom (serviceid, available) VALUES(%s, %s)" % (newserviceid, request.form['familyRoom'])
                insertSQL(sqlStatement)
                sqlStatement = "INSERT INTO Conditions (serviceid, conditions) VALUES (%s, '%s');" % (newserviceid, request.form['conditions2'])
                insertSQL(sqlStatement)
            return redirect('/viewServices')

        available = {}
        sqlStatement = "(SELECT * FROM Foodbank WHERE Foodbank.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
        available["foodBank"] = 'true' if fetchone(sqlStatement) != None else 'false'
        sqlStatement = "(SELECT * FROM FoodPantry WHERE FoodPantry.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
        available["foodPantry"] = 'true' if fetchone(sqlStatement) != None else 'false'
        sqlStatement = "(SELECT * FROM Shelter WHERE Shelter.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
        available["shelter"] = 'true' if fetchone(sqlStatement) != None else 'false'
        sqlStatement = "(SELECT * FROM SoupKitchen WHERE SoupKitchen.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
        available["soupKitchen"] = 'true' if fetchone(sqlStatement) != None else 'false'

        return render_template('addService.html', available=available)
    else:
        return redirect('/login')


@app.route('/foodBank', methods=['GET', 'POST','PUT', 'DELETE'])
def showFoodBank():

    if 'username' in session:
        sqlFoodbankId = """(SELECT Foodbank.serviceid FROM Foodbank INNER JOIN Service ON Foodbank.serviceid = Service.serviceid INNER JOIN Users ON Users.siteid = Service.siteid WHERE Users.username = '%s')""" % (session["username"])
        foodBankId = fetchone(sqlFoodbankId)

        if request.method == "POST" and request.form["_method"] == "PUT":
            sqlUpate = "UPDATE Items SET units=%s WHERE itemid=%s;" % (request.form["units"], request.form["itemId"])
            insertSQL(sqlUpate)
            return redirect('/foodBank')
        elif request.method == "POST" and request.form["_method"] == "POST":
            sqlInsert = "INSERT INTO Items(name, expdate, units, storagetype, itemtypeid, serviceid) VALUES('%s', %s, %s, '%s', %s, %s)" %(request.form["name"], request.form["expdate"], request.form["units"], request.form["storageType"], request.form["itemTypeId"], foodBankId[0])
            insertSQL(sqlInsert)
            return redirect('/foodBank')
        elif request.method == "POST" and request.form["_method"] == "DELETE":
            tmp = "(SELECT * FROM Foodbank WHERE Foodbank.serviceid IN (SELECT Service.serviceid FROM Users INNER JOIN Service ON Users.siteid = Service.siteid WHERE Users.username = '" + session["username"] + "'))"
            serviceid = str(fetchone(tmp)[0])
            if checkForLastService():
                error = 'CANNOT DELETE LAST SERVICE FROM SITE'
                return render_template('viewServices.html', available=getAvailability(), error=error)
            else:
                sqlUpate = "DELETE FROM Service WHERE Service.serviceid=%s" %(serviceid)
                insertSQL(sqlUpate)
                return redirect('/viewServices')
        elif request.method == "POST" and request.form["_method"] == "request":
            unitsApp  = request.form["unitsapproved"]
            requestID = request.form["requestid"]
            sqlGetItems = "SELECT I.units, I.itemid FROM Items AS I INNER JOIN ItemRequests AS IR WHERE IR.itemid=I.itemid AND IR.requestid=%s" % requestID
            resultsUnits = fetchone(sqlGetItems)
            if int(unitsApp) > int(resultsUnits[0]):
                flash('Too Many Items Approved')
            else:
                newUnits = int(resultsUnits[0])-int(unitsApp)
                sqlSubtractUnits = "UPDATE Items SET units=%s WHERE itemid=%s" % (newUnits,resultsUnits[1])
                sqlUpate = "UPDATE ItemRequests SET unitsapproved=%s WHERE requestid=%s;" % (unitsApp, requestID)
                insertSQL(sqlSubtractUnits)
                insertSQL(sqlUpate)
            return redirect('/foodBank')
        elif request.method == "DELETE":
            body = eval(request.form.get('data'))
            if "id" in body:
                print "Delete Item", body['id']
                sqlUpate = """DELETE FROM Items WHERE itemid = '%s' ;""" % (body['id'])
                insertSQL(sqlUpate)

        sqlItemSearch = """SELECT itemid, name, expdate, storagetype, units 
                          FROM Items WHERE serviceid = '%s' ;""" % foodBankId
        results = fetchall(sqlItemSearch)
        foodBankItems = []
        for x in results:
            i = {
                'itemid': x[0],
                'name': x[1],
                'expdate': x[2],
                'storagetype': x[3],
                'units': x[4]
            }
            foodBankItems.append(i)

        sqlItemSearch = "SELECT itemtypeid, typename FROM Itemtype;"
        results = fetchall(sqlItemSearch)
        itemTypes = []
        for x in results:
            i = {
                'itemtypeid': x[0],
                'typename': x[1]
            }
            itemTypes.append(i)

        sqlItemSearch = """SELECT ir.itemid,
                                CASE 
                                  WHEN Items.units < SUM(ir.unitsrequested) THEN 'R' 
                                  ELSE '' 
                                END AS isShortage   
                              FROM ItemRequests as ir 
                              INNER JOIN Items ON ir.itemid = Items.itemid 
                            WHERE ir.serviceidapproving = '%s' 
                            AND ir.unitsapproved IS NULL 
                            GROUP BY ir.itemid""" %(foodBankId)
        results = fetchall(sqlItemSearch)
        sqlItemRequests = """SELECT ir.requestid, ir.username, Items.units AS UnitsAvailable, Items.name AS ItemName,
                                ir.itemid, ir.unitsrequested
                              FROM ItemRequests as ir
                              INNER JOIN Items ON ir.itemid = Items.itemid
                            WHERE ir.serviceidapproving = %s
                            AND ir.unitsapproved IS NULL ;""" % foodBankId
        itemRequestsResults = fetchall(sqlItemRequests)
        itemRequests = []
        print results, 'results'
        print itemRequestsResults, 'itemrequests'
        for x in itemRequestsResults:
            itemid = x[4]
            shortage = ''
            for y in results:
                if itemid in y:
                    if y[1] == 'R':
                        shortage = 'R'
            i = {
                'requestid': x[0],
                'username': x[1],
                'unitsAvailable': x[2],
                'itemName': x[3],
                'itemid': itemid,
                'unitsrequested': x[5],
                'isShortage': shortage
            }
            itemRequests.append(i)
        return render_template('foodBank.html', foodBank=foodBankItems, itemTypes=itemTypes, itemsRequests=itemRequests)

    else:
        return redirect('/login')

@app.route('/outstandingRequestReport')
def showOutstandingRequestReport():
    if 'username' in session:
        return render_template('outstandingRequestReport.html')
    else:
        return redirect('/login')


@app.route('/soupKitchen', methods=['GET', 'POST','PUT', 'DELETE'])
def showSoupKitchen():
    if 'username' in session:
        sqlServiceId = """(SELECT SoupKitchen.serviceid FROM SoupKitchen 
                            WHERE SoupKitchen.serviceid IN (SELECT Service.serviceid 
                                FROM Users INNER JOIN Service ON Users.siteid = Service.siteid 
                                WHERE Users.username = '%s' ))""" % session["username"]
        serviceid = str(fetchone(sqlServiceId)[0])

        if request.method == "POST" and request.form["_method"] == "PUT":
            sqlUpdate = """UPDATE SoupKitchen 
                            SET SoupKitchen.description = '%s', SoupKitchen.seat = '%s'
                            WHERE SoupKitchen.serviceid = '%s' """ % (request.form["description"],
                                                                      request.form["seats"], str(serviceid))
            insertSQL(sqlUpdate)

            sqlUpdate = """UPDATE Conditions SET Conditions.conditions = '%s'
                             WHERE Conditions.serviceid = '%s' ;""" % (request.form["conditions"], serviceid)
            insertSQL(sqlUpdate)

            return redirect('/soupKitchen')
        elif request.method == "POST" and request.form["_method"] == "DELETE":
            if checkForLastService():
                error = 'CANNOT DELETE LAST SERVICE FROM SITE'
                return render_template('viewServices.html', available=getAvailability(), error=error)
            else:
                sqlUpdate = "DELETE FROM Service WHERE Service.serviceid=%s;" % (serviceid)
                insertSQL(sqlUpdate)
                return redirect('/viewServices')

        selectHO = """SELECT HoursOfOperation.id, Service.serviceid, HoursOfOperation.day, DATE_FORMAT(HoursOfOperation.open, '%%H:%%i'), 
                           DATE_FORMAT(HoursOfOperation.closed, '%%H:%%i') FROM Service 
                           INNER JOIN HoursOfOperation ON HoursOfOperation.serviceid = Service.serviceid 
                           WHERE HoursOfOperation.open IS NOT NULL 
                           AND Service.serviceid = %s 
                           ORDER BY FIELD(HoursOfOperation.day, 'MONDAY', 'MON', 
                              'TUESDAY', 'TUE', 'WEDNESDAY', 'WED', 'THURSDAY', 'THU', 'THUR', 'FRIDAY', 'FRI', 
                              'SATURDAY', 'SAT', 'SUNDAY', 'SUN'); """ % (serviceid)

        resultsHO = fetchall(selectHO)
        resultHO = []
        for ho in resultsHO:
            resultHO.append(dict({'id': ho[0],
                                  'serviceid': ho[1],
                                  'day': ho[2],
                                  'open': ho[3],
                                  'closed': ho[4]
                                  }))

        print resultHO

        sqlStatement = """SELECT SoupKitchen.seat, SoupKitchen.description, SoupKitchen.serviceid, Conditions.conditions
                            FROM Service
                            INNER JOIN SoupKitchen ON SoupKitchen.serviceid = Service.serviceid
                            INNER JOIN Conditions ON Conditions.serviceid = Service.serviceid
                            WHERE Service.serviceid = '%s'
                            """ % (serviceid)

        results = fetchone(sqlStatement)
        soupKitchen = {
                'seat': results[0],
                'description': results[1],
                'serviceid': results[2],
                'conditions': results[3]
            }

        return render_template('soupKitchen.html', soupKitchen=soupKitchen, resultHO=resultHO)
    else:
        return redirect('/login')

@app.route('/hours', methods=['GET', 'POST', 'PUT', 'DELETE'])
def showHours():
    if 'username' in session:

        print request.method, ' - ', request.form
        if request.method == "POST" and request.form["_method"] == "PUT":
            print "updateHOOButton"
            if len(request.form['id']) > 0 and len(request.form['open']) > 0 and len(
                    request.form['closed']) > 0 and len(request.form['day']) > 0:
                updateHOOQuery = """UPDATE HoursOfOperation SET 
                                                    HoursOfOperation.day = '%s' ,
                                                    HoursOfOperation.open = '%s' ,
                                                    HoursOfOperation.closed = '%s' 
                                                    WHERE HoursOfOperation.id = '%s' 
                                                    """ % (request.form['day'], request.form['open'],
                                                           request.form['closed'], request.form['id'])
                print updateHOOQuery
                insertSQL(updateHOOQuery)

        elif request.method == "POST" and request.form["_method"] == "POST":
            print "addHOOButton"
            if len(request.form['newDay']) > 0 and len(request.form['newOpen']) > 0 \
                    and len(request.form['newClosed']) > 0 and len(request.form['serviceid']) > 0:
                insertSql = """INSERT INTO HoursOfOperation(serviceid, day, open, closed) 
                                        VALUES ('%s', '%s', '%s', '%s');""" % (
                request.form['serviceid'], request.form['newDay'], request.form['newOpen'],
                request.form['newClosed'])
                print insertSql
                insertSQL(insertSql)
            else:
                print "Insert Failed. JSON data not passed!"

        elif request.method == "DELETE":
            print "delete HOO Button"
            body = eval(request.form.get('data'))
            if "id" in body:
                deleteSql = """DELETE FROM HoursOfOperation WHERE id= '%s' """ % (body["id"])
                insertSQL(deleteSql)
            else:
                print "Delete Failed. JSON data not passed!"
            if len(body['returnPage']) > 0:
                return redirect(body['returnPage'])

    if len(request.form['returnPage']) > 0:
        return redirect(request.form['returnPage'])
    else:
        return redirect('/login')


@app.route('/shelter', methods=['GET', 'POST', 'PUT', 'DELETE', 'MOVEUP', 'MOVEDOWN', 'POSTHOUR', 'DELETEHOO'])
def showSheleter():
    if 'username' in session:

        sqlServiceId = """(SELECT Shelter.serviceid FROM Shelter 
                                            WHERE Shelter.serviceid IN (SELECT Service.serviceid 
                                                FROM Users INNER JOIN Service ON Users.siteid = Service.siteid 
                                                WHERE Users.username = '%s' ))""" % session["username"]
        serviceid = str(fetchone(sqlServiceId)[0])

        print request.method , '-', request.form
        if request.method == "POST" and request.form["_method"] == "PUT":
            sqlUpdate = """UPDATE Shelter 
                            SET Shelter.description = '%s'
                            WHERE Shelter.serviceid = '%s' ;""" % (request.form["description"], serviceid)
            insertSQL(sqlUpdate)

            sqlUpdate = """UPDATE Bunks 
                            SET Bunks.maleavailable = '%s',
                            Bunks.femaleavailable = '%s', 
                            Bunks.mixavailable = '%s' 
                            WHERE Bunks.serviceid = '%s' ;""" % (request.form["malecount"],
                                                                 request.form["femalecount"],
                                                                 request.form["mixcount"],
                                                                 serviceid)
            insertSQL(sqlUpdate)

            sqlUpdate = """UPDATE FamilyRoom SET FamilyRoom.available = '%s'
                                        WHERE FamilyRoom.serviceid = '%s' ;""" % (request.form["roomsavailable"], serviceid)
            insertSQL(sqlUpdate)

            sqlUpdate = """UPDATE Conditions SET Conditions.conditions = '%s'
                              WHERE Conditions.serviceid = '%s' ;""" % (request.form["conditions"], serviceid)
            insertSQL(sqlUpdate)

            return redirect("/shelter")
        elif request.method == "POST" and request.form["_method"] == "DELETE":
            if checkForLastService():
                error = 'CANNOT DELETE LAST SERVICE FROM SITE'
                return render_template('viewServices.html', available=getAvailability(), error=error)
            else:
                sqlUpdate = "DELETE FROM Service WHERE Service.serviceid=%s;" % (serviceid)
                insertSQL(sqlUpdate)
                return redirect('/viewServices')

        elif request.method == "DELETE":
            body = eval(request.form.get('data'))
            if "waitlistid" in body and "rankorder" in body:
                sqlUpdate = """UPDATE Waitlist SET rankorder = rankorder - 1 WHERE rankorder > %s AND serviceid = %s  """ % (int(body["rankorder"]), serviceid)
                insertSQL(sqlUpdate)

                sqlDelete = "DELETE FROM Waitlist WHERE Waitlist.waitlistid=%s" % (str(body["waitlistid"]))
                insertSQL(sqlDelete)
            else:
                print "Delete Failed. JSON data not passed!"

        elif request.method == "MOVEUP" or request.method == "MOVEDOWN":
            isMoveDown = 1
            if request.method == "MOVEUP":
                isMoveDown = -1
            body = eval(request.form.get('data'))
            if "waitlistid" in body and "rankorder" in body:

                sqlSelect = """SELECT w.waitlistid FROM Waitlist w WHERE w.rankorder = %s AND w.serviceid = %s """ % (int(body["rankorder"])+isMoveDown, serviceid)
                waitlistid2 = fetchone(sqlSelect)

                if waitlistid2:
                    sqlUpdate = """UPDATE Waitlist AS t1
                                    JOIN Waitlist AS t2 ON
                                    (
                                        t1.waitlistid = %s 
                                        AND t2.waitlistid = %s
                                    )
                                    SET
                                    t1.rankorder = t2.rankorder,
                                    t2.rankorder = t1.rankorder;""" % (int(body["waitlistid"]), waitlistid2[0])
                    insertSQL(sqlUpdate)
                else:
                    print "Can't move! Already Max/Min!"
            else:
                print "Move Failed. JSON data not passed!"

        selectHO = """SELECT HoursOfOperation.id, Service.serviceid, HoursOfOperation.day, DATE_FORMAT(HoursOfOperation.open, '%%H:%%i'), 
                   DATE_FORMAT(HoursOfOperation.closed, '%%H:%%i') FROM Service 
                   INNER JOIN HoursOfOperation ON HoursOfOperation.serviceid = Service.serviceid 
                   WHERE HoursOfOperation.open IS NOT NULL 
                   AND Service.serviceid = %s 
                   ORDER BY FIELD(HoursOfOperation.day, 'MONDAY', 'MON', 
                      'TUESDAY', 'TUE', 'WEDNESDAY', 'WED', 'THURSDAY', 'THU', 'THUR', 'FRIDAY', 'FRI', 
                      'SATURDAY', 'SAT', 'SUNDAY', 'SUN');""" % (serviceid)

        resultsHO = fetchall(selectHO)
        resultHO = []
        for ho in resultsHO:
            resultHO.append(dict({'id': ho[0],
                            'serviceid': ho[1],
                            'day': ho[2],
                            'open': ho[3],
                            'closed': ho[4]
                            }))


        print resultHO

        selectBunksRooms = """SELECT Service.serviceid, Bunks.maleavailable, Bunks.femaleavailable, Bunks.mixavailable, 
                                Bunks.malemax, Bunks.femalemax, Bunks.mixmax, 
                                FamilyRoom.available, FamilyRoom.maxrooms, Shelter.description, Conditions.conditions
                           FROM Service 
                           INNER JOIN Bunks ON Bunks.serviceid = Service.serviceid 
                           INNER JOIN FamilyRoom ON FamilyRoom.serviceid = Service.serviceid 
                           INNER JOIN Shelter ON Shelter.serviceid = Service.serviceid 
                           INNER JOIN Conditions ON Conditions.serviceid = Service.serviceid
                           WHERE Service.serviceid = %s;""" % (serviceid)

        resultBR = fetchall(selectBunksRooms)[0]

        print resultBR

        shelter = {
            'serviceid': resultBR[0],
            'malecount': resultBR[1],
            'femalecount': resultBR[2],
            'mixcount': resultBR[3],
            'malemax': resultBR[4],
            'femalemax': resultBR[5],
            'mixmax': resultBR[6],
            'roomsavailable': resultBR[7],
            'maxrooms': resultBR[8],
            'description': resultBR[9],
            'conditions': resultBR[10]
        }

        sqlStatement = """SELECT Waitlist.waitlistid, Waitlist.clientid, Waitlist.rankorder 
                            FROM Waitlist WHERE Waitlist.serviceid= %s 
                            ORDER BY Waitlist.rankorder, Waitlist.clientid""" % serviceid
        result = fetchall(sqlStatement)
        waitlist = []

        for x in result:
            i = {
                'waitlistid': x[0],
                'clientid': x[1],
                'rankorder': x[2]
            }
            waitlist.append(i)
        hoNew = ('', '', '')

        return render_template('shelter.html', shelter=shelter, resultHO=resultHO, waitlist=waitlist, hoNew=hoNew)
    else:
        return redirect('/login')


@app.route('/foodPantry', methods=['GET', 'POST','PUT', 'DELETE'])
def showFoodPantry():
    print request.method, '-', request.form
    if 'username' in session:
        sqlServiceId = """(SELECT FoodPantry.serviceid FROM FoodPantry 
                            WHERE FoodPantry.serviceid IN (SELECT Service.serviceid 
                                FROM Users INNER JOIN Service ON Users.siteid = Service.siteid 
                                WHERE Users.username = '%s' ))""" % session["username"]
        serviceid = str(fetchone(sqlServiceId)[0])

        if request.method == "POST" and request.form["_method"] == "PUT":
            sqlUpdate = """UPDATE FoodPantry SET FoodPantry.description='%s' 
                            WHERE FoodPantry.serviceid=%s""" %(request.form["description"], serviceid)
            insertSQL(sqlUpdate)

            sqlUpdate = """UPDATE Conditions SET Conditions.conditions = '%s'
                            WHERE Conditions.serviceid = '%s' ;""" % (request.form["conditions"], serviceid)
            insertSQL(sqlUpdate)

            return redirect("/foodPantry")
        elif request.method == "POST" and request.form["_method"] == "DELETE":
            if checkForLastService():
                error = 'CANNOT DELETE LAST SERVICE FROM SITE'
                return render_template('viewServices.html', available=getAvailability(), error=error)
            else:
                sqlDelete = "DELETE FROM Service WHERE Service.serviceid=%s" % (serviceid)
                insertSQL(sqlDelete)
                return redirect("/viewServices")

        selectHO = """SELECT HoursOfOperation.id, Service.serviceid, HoursOfOperation.day, DATE_FORMAT(HoursOfOperation.open, '%%H:%%i'), 
                           HoursOfOperation.closed FROM Service 
                           INNER JOIN HoursOfOperation ON HoursOfOperation.serviceid = Service.serviceid 
                           WHERE HoursOfOperation.open IS NOT NULL 
                           AND Service.serviceid = %s 
                           ORDER BY FIELD(HoursOfOperation.day, 'MONDAY', 'MON', 
                              'TUESDAY', 'TUE', 'WEDNESDAY', 'WED', 'THURSDAY', 'THU', 'THUR', 'FRIDAY', 'FRI', 
                              'SATURDAY', 'SAT', 'SUNDAY', 'SUN');""" % (serviceid)

        resultsHO = fetchall(selectHO)
        resultHO = []
        for ho in resultsHO:
            resultHO.append(dict({'id': ho[0],
                                  'serviceid': ho[1],
                                  'day': ho[2],
                                  'open': ho[3],
                                  'closed': ho[4]
                                  }))

        print resultHO

        sqlStatement = """SELECT FoodPantry.serviceid, FoodPantry.description, Conditions.conditions
            FROM Service
            INNER JOIN FoodPantry ON FoodPantry.serviceid = Service.serviceid
            INNER JOIN Conditions ON Conditions.serviceid = Service.serviceid
            WHERE Service.serviceid =%s
            """ %(serviceid)
        result = fetchone(sqlStatement)

        pantry = {
            'serviceid': result[0],
            'description': result[1],
            'conditions': result[2]
        }
        return render_template('foodPantry.html', pantry=pantry, resultHO=resultHO)
    else:
        return redirect('/login')


@app.route('/bedroomReport')
def showBedroomReport():

        selectShelter = "SELECT DISTINCT Shelter.serviceid, Shelter.description FROM Service "\
                            "INNER JOIN Shelter ON Shelter.serviceid = Service.serviceid " \
                            "INNER JOIN HoursOfOperation ON HoursOfOperation.serviceid = Service.serviceid "\
                            "INNER JOIN Bunks ON Bunks.serviceid = Service.serviceid "\
                            "INNER JOIN FamilyRoom ON FamilyRoom.serviceid = Service.serviceid "\
                        "WHERE HoursOfOperation.open IS NOT NULL "\
                        "AND Bunks.maleavailable IS NOT NULL "\
                        "AND FamilyRoom.available IS NOT NULL "\
                        "AND Service.serviceid IN (SELECT Shelter.serviceid FROM Shelter) "\
                        "ORDER BY Shelter.serviceid;"

        resultShelter = fetchall(selectShelter)

        print resultShelter

        selectHO = "SELECT Service.serviceid, HoursOfOperation.day, DATE_FORMAT(HoursOfOperation.open, '%H:%i') as open, " \
                   "DATE_FORMAT(HoursOfOperation.closed, '%H:%i') as closed FROM Service "\
                "INNER JOIN HoursOfOperation ON HoursOfOperation.serviceid = Service.serviceid "\
            "WHERE HoursOfOperation.open IS NOT NULL "\
            "AND Service.serviceid IN (SELECT Shelter.serviceid FROM Shelter);"

        resultsHO = fetchall(selectHO)
        resultHO = []
        for ho in resultsHO:
            resultHO.append(dict({'serviceid': ho[0],
                                  'day': ho[1],
                                  'open': ho[2],
                                  'closed': ho[3]
                                  }))

        print resultHO

        selectBunksRooms =  """SELECT Service.serviceid as serviceid, Bunks.maleavailable as maleAvail, Bunks.malemax as maleMax, 
                            Bunks.femaleavailable as femaleAvail, Bunks.femalemax as femaleMax, Bunks.mixavailable as mixAvail, 
                            Bunks.mixmax as mixMax, FamilyRoom.available as famAvail, FamilyRoom.maxrooms as maxRooms, 
                            Site.sitename as sitename, Site.phone as phone, Conditions.conditions 
                            FROM Service 
                                INNER JOIN Bunks ON Bunks.serviceid = Service.serviceid 
                                INNER JOIN FamilyRoom ON FamilyRoom.serviceid = Service.serviceid 
                                INNER JOIN Site ON Site.siteid = Service.siteid 
                                INNER JOIN Conditions ON Conditions.serviceid = Service.serviceid 
                            WHERE Service.serviceid IN (SELECT Shelter.serviceid FROM Shelter);"""

        resultBR = fetchall(selectBunksRooms)

        print resultBR

        return render_template('bedroomReport.html', session=session,
                               resultShelter=resultShelter, resultHO=resultHO, resultBR=resultBR)



@app.route('/itemRequestStatusReport')
def showItemRequestStatusReport():
    if 'username' in session:
        return render_template('itemRequestStatusReport.html', session=session, results=getRequests())
    else:
        return redirect('/login')

@app.route('/clientSearch', methods=['GET', 'POST'])
def showClientSearch():
    error = None
    clientlist = None
    if request.method == 'POST':
        if request.form['button'] == 'searchButton':
            # Search for a client by a name string
            if len(request.form['clientSearchString']) > 0:
                searchString = request.form['clientSearchString']
            else:
                searchString = 'NULL'
            if len(request.form['clientIDnumber']) > 0:
                idString = request.form['clientIDnumber']
            else:
                idString = 'NULL'
            sqlStatement = """
                SELECT clientid, firstname, lastname 
                FROM cs6400_sp17_team092.clients
                WHERE lower(CONCAT(firstname,' ',lastname)) LIKE lower('%%%s%%')
                OR clientid = %s""" % (searchString, idString)
            result = fetchall(sqlStatement)

            if len(result) > 4:
                error = "Be More Specific in Your Search String"
                result = (("NA","NA","NA"),("NA","NA","NA"))

            clientlist = []
            for x in result:
                clients = {
                    'clientid': x[0],
                    'firstname': x[1],
                    'lastname': x[2]
                }
                clientlist.append(clients)

    return render_template('clientSearch.html', results=clientlist, error=error)

@app.route('/clientReport', methods=['GET', 'POST', 'PUT', 'DELETE'])
def showClientReport():
    if 'username' in session:
        summary = []
        waitlist = []
        clientlog = []
        if request.method == "POST":
            if request.form['button'] == 'getclientinfo':
                clientid = request.form['clientIDnumber']
                sqlStatement = """
                SELECT *
                FROM cs6400_sp17_team092.clients
                WHERE clientid = %s""" % clientid
                result = fetchone(sqlStatement)

                summary = {
                    'clientid': result[0],
                    'firstname': result[1],
                    'lastname': result[2],
                    'phone': result[3],
                    'iddescription': result[4],
                    'headofhousehold': result[5]
                    }

                sqlStatement2 = """
                SELECT b.description, a.rankorder 
                FROM cs6400_sp17_team092.waitlist a
                LEFT JOIN cs6400_sp17_team092.shelter b
                ON a.serviceid = b.serviceid
                WHERE clientid = %s """ % clientid
                result2 = fetchall(sqlStatement2)

                for x in result2:
                    wl_entry = {
                        'description': x[0],
                        'waitlistorder': x[1]
                    }
                    waitlist.append(wl_entry)

                sqlStatement3 = """
                SELECT a.clientlogid, a.timestp, a.description,  b.sitename, a.username  
                FROM cs6400_sp17_team092.clientlog a
                LEFT JOIN cs6400_sp17_team092.site b
                ON a.siteid = b.siteid
                WHERE a.clientid = %s
                ORDER BY a.timestp DESC""" % clientid
                result3 = fetchall(sqlStatement3)

                for x in result3:
                    cl_entry = {
                        'clientlogid': x[0],
                        'timestp': x[1],
                        'description': x[2],
                        'sitename': x[3],
                        'username': x[4]
                    }
                    clientlog.append(cl_entry)


        return render_template('clientReport.html', summary=summary, waitlist = waitlist, clientlog = clientlog)
    else:
        return redirect('/login')

@app.route('/itemRequestStatusReport', methods=['GET', 'POST'])
def updateMyItemRequests():
    error = None
    successLog = None
    if request.method == 'POST':
        ### Edit Button
        if request.form['button'] == 'editButton':
            requestID = request.form['requestID']
            updateUnitsReq = request.form['units']
            if not requestID or not updateUnitsReq:
                error = 'ENTER IN A VALUE'
            else:
                sqlCheckRequestID = "SELECT R.unitsrequested, R.unitsapproved, I.units FROM " \
                                    "ItemRequests AS R INNER JOIN Items AS I WHERE R.requestid=%s AND R.username=%s " \
                                    "AND R.itemid=I.itemid" % (requestID, session['username'])
                returnCheckRequestID = fetchone(sqlCheckRequestID)
                if not returnCheckRequestID:
                    error = "NOT A MATCHING REQUEST ID"
                else:
                    unitsReq = returnCheckRequestID[0]
                    unitsApp = returnCheckRequestID[1]
                    unitsTotal = returnCheckRequestID[2]
                    if unitsApp:
                        error = "CLOSED REQUEST. CANNOT EDIT"
                    elif int(updateUnitsReq) > int(unitsTotal):
                        error = "REQUESTED TOO MANY UNITS OF ITEM"
                    elif int(updateUnitsReq) == int(unitsReq):
                        error = "SAME NUMBER OF UNITS REQUESTED"
                    else:
                        sqlUpdateItemReq = "UPDATE ItemRequests SET unitsrequested=%s WHERE requestid=%s" % (updateUnitsReq, requestID)
                        successEdit = insertSQL(sqlUpdateItemReq)
                        if successEdit:
                            flash('Successful Edit')
                            return redirect('/itemRequestStatusReport')
                        else:
                            error = "Unable to Edit Item"
            return render_template('itemRequestStatusReport.html', error=error, successLog=successLog, session=session, results=getRequests())
        ### Cancel Button
        elif request.form['button'] == 'cancelButton':
            requestID = request.form['requestID']
            updateUnitsReq = request.form['units']
            if not requestID:
                error = 'ENTER IN A REQUEST ID TO CANCEL'
            else:
                sqlCheckRequestID = "SELECT R.unitsrequested, R.unitsapproved, I.units FROM " \
                                    "ItemRequests AS R INNER JOIN Items AS I WHERE R.requestid=%s AND R.username=%s " \
                                    "AND R.itemid=I.itemid" % (requestID, session['username'])
                returnCheckRequestID = fetchone(sqlCheckRequestID)
                if not returnCheckRequestID:
                    error = "NOT A MATCHING REQUEST ID"
                else:
                    unitsApp = returnCheckRequestID[1]
                    print unitsApp, 'unitsapps'
                    if unitsApp == None:
                        sqlCancelItemReq = "UPDATE ItemRequests SET unitsapproved=0 WHERE requestid=%s" % requestID
                        successCancel = insertSQL(sqlCancelItemReq)
                        if successCancel:
                            flash('Successful Cancel')
                            return redirect('/itemRequestStatusReport')
                        else:
                            error = "Unable to Edit Item"
                    else:
                        error = "CAN'T CANCEL A CLOSED REQUEST"

            return render_template('itemRequestStatusReport.html', error=error, successLog=successLog, session=session,
                                   results=getRequests())
        else:
            return redirect('/mainmenu')
    else:
        return redirect('/itemRequestStatusReport')



@app.route('/editClientInfo', methods=['GET', 'POST', 'PUT', 'DELETE'])
def editClientInformation():
    if 'username' in session:
        summary = []
        clientlog = []
        error = None
        if request.method == "POST":
            if request.form['button'] == 'editButton':
                usrname = str(session["username"])
                clientid = request.form['clientid']
                siteid = fetchone("SELECT siteid FROM cs6400_sp17_team092.users WHERE username ='" + usrname + "'")[0]
                log_event = "".join(str(v) for v in ["INSERT INTO cs6400_sp17_team092.clientlog (clientid, timestp, siteid, description, username) VALUES (",clientid, ", NOW(), '", siteid,"', 'edited client profile', '",usrname,"')"])
                insertSQL(log_event)
                if len(clientid) == 0:
                    error = "You need to specify a Client ID. Check Client Search to look up a client's ID number."
                    return render_template('editClientInfo.html', summary = summary, error = error)
                if len(request.form['clientfirstname']) > 0:
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET firstname = '" + request.form['clientfirstname'] + "' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)
                if len(request.form['clientlastname']) > 0:
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET lastname = '" + request.form['clientlastname'] + "' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)
                if len(request.form['clientiddescription']) > 0:
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET iddescription = '" + request.form['clientiddescription'] + "' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)
                if len(request.form['clientphone']) > 0:
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET phone = '" + request.form['clientphone'] + "' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)
                if request.form['category'] == 'Yes':
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET headofhousehold = '1' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)
                if request.form['category'] == 'No':
                    sqlUpdate = "UPDATE cs6400_sp17_team092.clients SET headofhousehold = '0' WHERE clientid =" + clientid
                    insertSQL(sqlUpdate)

                print clientid
                sqlStatement = """
                SELECT *
                FROM cs6400_sp17_team092.clients
                WHERE clientid = %s""" % clientid
                result = fetchone(sqlStatement)

                summary = {
                    'clientid': result[0],
                    'firstname': result[1],
                    'lastname': result[2],
                    'phone': result[3],
                    'iddescription': result[4],
                    'headofhousehold': result[5]
                    }

            if request.form['button'] == 'serviceButton':
                usrname = str(session["username"])
                clientid = request.form['clientid']
                service_dsc = request.form['description']
                if len(clientid) == 0:
                    error = "You need to specify a Client ID. Check Client Search to look up a client's ID number."
                    return render_template('editClientInfo.html', summary = summary, error = error)
                siteid = fetchone("SELECT siteid FROM cs6400_sp17_team092.users WHERE username ='" + usrname + "'")[0]
                sqlStatement2 = "".join(str(v) for v in ["INSERT INTO cs6400_sp17_team092.clientlog (clientid, timestp, siteid, description, username) VALUES (",clientid, ", NOW(), '", siteid,"', '",service_dsc,"', '",usrname,"')"])
                print sqlStatement2
                insertSQL(sqlStatement2)
                log_event2 = "".join(str(v) for v in ["INSERT INTO cs6400_sp17_team092.clientlog (clientid, timestp, siteid, description, username) VALUES (",clientid, ", NOW(), '", siteid, "', 'edited client service log', '", usrname, "')"])
                insertSQL(log_event2)


                sqlStatement3 = """
                SELECT a.clientlogid, a.timestp, a.description,  b.sitename, a.username  
                FROM cs6400_sp17_team092.clientlog a
                LEFT JOIN cs6400_sp17_team092.site b
                ON a.siteid = b.siteid
                WHERE a.clientid = %s
                ORDER BY a.timestp DESC""" % request.form['clientid']
                result3 = fetchall(sqlStatement3)

                for x in result3:
                    cl_entry = {
                        'clientlogid': x[0],
                        'timestp': x[1],
                        'description': x[2],
                        'sitename': x[3],
                        'username': x[4]
                    }
                    clientlog.append(cl_entry)


        return render_template('editClientInfo.html', summary = summary, error = error, clientlog = clientlog)
    else:
        return redirect('/login')

@app.route('/mealsAvailableReport')
def showMealsAvailableReport():
    if request.method == "GET":
        sqlStatement = """
        SELECT mealpart AS neededdonation, min(totalunits) AS minimummeals
        FROM (SELECT CASE WHEN ItemType.typename = "Meat/Seafood" OR
            ItemType.typename = "Dairy/Eggs" THEN "Meat/Seafood/Dairy/Eggs" ELSE
            ItemType.typename END AS mealpart,
            sum(Items.units) AS totalunits
            FROM Items
            INNER JOIN
            ItemType ON Items.itemtypeid = ItemType.itemtypeid
            WHERE ItemType.typename IN ("Vegetables", "Nuts/Grains/Beans", "Meat/Seafood", "Dairy/Eggs")
        GROUP BY mealpart ORDER BY totalunits ASC) zz;           
        """
        result = fetchone(sqlStatement)
        most_needed = {'most_needed': result[0]}
        meals_avail = {'meals_avail': result[1]}
        itemcount = fetchall("""
            SELECT CASE WHEN ItemType.typename = "Meat/Seafood" OR
                ItemType.typename = "Dairy/Eggs" THEN "Meat/Seafood/Dairy/Eggs" ELSE
                ItemType.typename END AS mealpart,
                sum(Items.units) AS totalunits
                FROM Items
                INNER JOIN
                ItemType ON Items.itemtypeid = ItemType.itemtypeid
                WHERE ItemType.typename IN ("Vegetables", "Nuts/Grains/Beans", "Meat/Seafood", "Dairy/Eggs")
            GROUP BY mealpart""")
        pie_chart = pygal.Pie()
        pie_chart.title = 'Meal Items Available'
        pie_chart.add(itemcount[0][0], itemcount[0][1])
        pie_chart.add(itemcount[1][0], itemcount[1][1])
        pie_chart.add(itemcount[2][0], itemcount[2][1])
        return render_template('mealsAvailableReport.html', most_needed = most_needed, meals_avail = meals_avail, pie_chart = pie_chart)


### not sure if we need to close DB.  Causes issues when just running.
# @app.teardown_appcontext
# def close_db(error):
#     """Closes the database again at the end of the request."""
#     mysql.teardown_request(error)

if __name__ == '__main__':
    app.run()