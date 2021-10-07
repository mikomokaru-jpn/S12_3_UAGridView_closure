## macOS S12_UAGridView
## Create a list

<img src="http://mikomokaru.sakura.ne.jp/data/B32/gridObject3.png" alt="grid" title="grid" width="400">

To display table data as a list in Swift, it is common to use NSTableView class. This application provides a way to display a list with simple parameter settings without implementing delegate methods. User specifies attributes of a list such as the number of columns, column widthes, a row height, and creates an array of dictionaries to be passed as data source.

### Sort by column as key

You can sort records by column as a key. A sort button is added to the column headings.Click it to sort records using that column as a key. Each time you click the button, ascending or descending order is switched. The sort order is displayed as an arrow in the button title.

### Change cell attributes with conditions

The text color and background color of a specific display value can be changed dipending on record values. The condition can be based on multiple values.
In the following, [Pulse pressure] and [Average blood pressure] are marked in red when their values exceed normal values. The background color of [lowest blood pressure] and [highest blood pressure] are yellow when either the diastolic blood pressure or the systolic blood pressure exceeds their normal value, and red when both of them are exceeded. Also, [Date] is inserted slashes between year, month, and day.
