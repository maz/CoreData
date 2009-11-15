/*
 * AppController.j
 * CoreData
 *
 * Created by You on November 13, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

//Thanks for CappuccinoCasts.com I know very little about CPTableView so I borrowed some of their code

@import <AppKit/AppKit.j>
@import "CoreData.j"


@implementation AppController : CPObject
{
	CPTableView tableView;
	CPArray data;
	ManagedObjectContext ctx;
	CPSearchField searchField;
	IBOutlet nameField;
	IBOutlet ageField;
	IBOutlet streetField;
	IBOutlet cityField;
	IBOutlet stateField;
	IBOutlet zipcodeField;
	IBOutlet form;
	CPView contentView;
	CPImage spinnerImage;
	CPImageView spinner;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
	contentView = [theWindow contentView];
		spinnerImage=[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:"loading.gif"]];
		spinner=[[CPImageView alloc] initWithFrame:CPMakeRect(0,0,100,100)];
		[spinner setImage:spinnerImage];
		searchField = [[CPSearchField alloc] initWithFrame:CGRectMake(0.0, 10.0, 200.0, 30.0)];
		[searchField setEditable:YES];
		[searchField setPlaceholderString:@"search and hit enter"];
		[searchField setBordered:YES];
		[searchField setBezeled:YES];
		[searchField setFont:[CPFont systemFontOfSize:12.0]];
		[searchField setTarget:self];
		[searchField setAction:@selector(performSearch:)];
		
		var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 50.0, 965.0, 200.0)];
			[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
			
		var delButton=[CPButton buttonWithTitle:"Delete"];
		[delButton setFrameOrigin:CPMakePoint(2,275)];
		[delButton setTarget:self];
		[delButton setAction:@selector(deleteRow:)];
		[contentView addSubview:delButton];
		
		[CPBundle loadCibNamed:@"form" owner:self loadDelegate:self];
		
		tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
		[tableView setDataSource:self];
		[tableView setDelegate:self];
		[tableView setUsesAlternatingRowBackgroundColors:YES];

		// define the header color
		var headerColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"button-bezel-center.png"]]];

		[[tableView cornerView] setBackgroundColor:headerColor];


		// add the first column
		var column = [[CPTableColumn alloc] initWithIdentifier:@"Name"];
		[[column headerView] setStringValue:"Name"];
		[[column headerView] setBackgroundColor:headerColor];
		[column setWidth:125.0];
		[tableView addTableColumn:column];

		// add the second column
		var column = [[CPTableColumn alloc] initWithIdentifier:@"Age"];
		[[column headerView] setStringValue:"Age"];
		[[column headerView] setBackgroundColor:headerColor];
		[column setWidth:825.0];
		[tableView addTableColumn:column];

		[scrollView setDocumentView:tableView];

		[contentView addSubview:searchField];
		[contentView addSubview:scrollView];
		[contentView addSubview:spinner];
		[spinner setCenter:[scrollView center]];

	[theWindow orderFront:self];

	// Uncomment the following line to turn on the standard menu bar.
	//[CPMenu setMenuBarVisible:YES];
	ctx=[[ManagedObjectContext alloc] initWithRoot:"/"];
	[ctx queryEntity:"people" sortKey:"name" clause:{} withCallback:function(arr){
		data=arr;
		[tableView reloadData];
		[spinner setHidden:YES];
	}];
}

-(void)cibDidFinishLoading:(CPCib)aCib
{
	[form setFrameOrigin:CPMakePoint(2,300)];
	[contentView addSubview:form];
}

-(IBAction)update:(id)sender
{
	var idxSet=[tableView selectedRowIndexes];
	if([idxSet count]){
		var obj=data[[idxSet firstIndex]];
		[obj setValue:[nameField stringValue] forKey:"name"];
		[obj setValue:[ageField stringValue] forKey:"age"];
		[obj setValue:[streetField stringValue] forKey:"street"];
		[obj setValue:[cityField stringValue] forKey:"city"];
		[obj setValue:[stateField stringValue] forKey:"state"];
		[obj setValue:[zipcodeField stringValue] forKey:"zipcode"];
		[spinner setHidden:NO];
		[obj saveWithCallback:function(res){
			if(res){
				[self performSearch:searchField];
			}else{
				[self showErrors:[obj errors]];
			}
		}];
	}
}

-(void)showErrors:(CPArray)err{
	[spinner setHidden:YES];
	var win=[[CPWindow alloc] initWithContentRect:CPMakeRect(0,0,300,300) styleMask:CPTitledWindowMask|CPClosableWindowMask|CPResizableWindowMask];
	var wv=[[CPWebView alloc] initWithFrame:CPMakeRect(0,0,300,300)];
	[wv loadHTMLString:[ManagedObject htmlWithErrors:err andTitle:"Errors"]];
	[win setContentView:wv];
	[win orderFront:nil];
	[win center];
	[wv setAutoresiingeMask:CPViewWidthSizable|CPViewHeightSizable];
}

-(IBAction)add:(id)sender
{
	var obj=[[ManagedObject alloc] initWithEntity:"people" andContext:ctx];
	[obj setValue:[nameField stringValue] forKey:"name"];
	[obj setValue:[ageField stringValue] forKey:"age"];
	[obj setValue:[streetField stringValue] forKey:"street"];
	[obj setValue:[cityField stringValue] forKey:"city"];
	[obj setValue:[stateField stringValue] forKey:"state"];
	[obj setValue:[zipcodeField stringValue] forKey:"zipcode"];
	[spinner setHidden:NO];
	[obj saveWithCallback:function(res){
		if(res){
			[self performSearch:searchField];
		}else{
			[self showErrors:[obj errors]];
		}
	}];
}

-(IBAction)deleteRow:(id)sender
{
	var idxSet=[tableView selectedRowIndexes];
	if([idxSet count]){
		var obj=data[[idxSet firstIndex]];
		[spinner setHidden:NO];
		[obj destroyWithCallback:function(){
			[self performSearch:searchField];
		}];
	}
}

-(IBAction)performSearch:(CPSearchField)sf
{
	var c=[sf stringValue]?{name:[sf stringValue]}:{};
	[spinner setHidden:NO];
	[ctx queryEntity:"people" sortKey:"name" clause:c withCallback:function(arr){
		data=arr;
		[tableView reloadData];
		[spinner setHidden:YES];
	}];
}

-(void)tableViewSelectionDidChange:(CPNotification)note
{
	var idxSet=[tableView selectedRowIndexes];
	if([idxSet count]){
		var obj=data[[idxSet firstIndex]];
		[nameField setStringValue:[obj valueForKey:"name"]];
		[ageField setStringValue:[obj valueForKey:"age"]];
		[streetField setStringValue:[obj valueForKey:"street"]];
		[cityField setStringValue:[obj valueForKey:"city"]];
		[stateField setStringValue:[obj valueForKey:"state"]];
		[zipcodeField setStringValue:[obj valueForKey:"zipcode"]];
	}
}

// ---
// CPTableView datasource methods
- (int)numberOfRowsInTableView:(CPTableView)tableView
{
	return [data count];
}
 
- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
	if ([tableColumn identifier]=="Age")
		return [data[row] valueForKey:"age"];
	else
		return [data[row] valueForKey:"name"];
}

@end
