var ManagedObjectClasses={};

@implementation ManagedObjectContext : CPObject
{
	CPString root;
}

- (id)initWithRoot:(CPString)r
{
	if(self = [super init])
	{
		root=r;
		if(root.charAt(root.length-1)!='/'){
			root+='/';
		}
	}
	return self;
}

-(void)queryEntity:(CPString)entity sortKey:(CPString)skey clause:(Object)c withCallback:(Function)cb
{
	var url=root+entity;
	url+="?sort="+encodeURIComponent(skey);
	if(c){
		url+="&clause="+encodeURIComponent(JSON.stringify(c));
	}
	var op=objj_request_xmlhttp();
	op.open('get',url,true);
	op.setRequestHeader('Accept','application/json');
	op.onreadystatechange=function(){
		if(op.readyState==4){
			op.onreadystatechange=null;
			var arr=JSON.parse(op.responseText);
			var cls=ManagedObjectClasses[entity]||ManagedObject;
			var a=[];
			for(var i=0;i<arr.length;i++){
				var obj=[[ManagedObject alloc] initWithEntity:entity andContext:self];
				obj.ident=arr[i].id;
				delete arr[i].id;
				obj.fields=arr[i];
				a.push(obj);
			}
			cb(a);
		}
	};
	op.send(null);
}

+(void)setClass:(Class)cls forName:(CPString)name
{
	ManagedObjectClasses[name]=cls;
}

@end

@implementation ManagedObject : CPObject
{
	ManagedObjectContext ctx;
	CPString entity;
	CPNumber ident;
	Object fields;
	CPArray errors;
}

//the CSS code below is from nifty-layout from nifty-generators (http://github.com/ryanb/nifty-generators)

+(CPString)htmlWithErrors:(CPArray)errors andTitle:(CPString)t
{
	var html="<!DOCTYPE HTML>\n<html><head><title>"+t+"</title></head><body>";
	html+="<div style=\"width: 400px;border: 2px solid #CF0000;padding: 0px;padding-bottom: 12px;margin-bottom: 20px;background-color: #f0f0f0;\">";
	html+="<h2 style=\"text-align: left;font-weight: bold;padding: 5px 5px 5px 15px;font-size: 12px;margin: 0;background-color: #c00;color: #fff;\">"+[errors count]+(([errors count]!=1)?" Errors":" Error")+" prevented this entity from being saved.</h2>";
	html+="<p style=\"color: #333;margin-bottom: 0;padding: 8px;\">There were problems with the following fields:</p>";
	html+="<ul style=\"margin: 2px 24px;\">"
	for(var i=0;i<errors.length;i++){
		html+="<li style=\"font-size: 12px;list-style: disc;\">";
		html+=errors[i].join(" ");
		html+="</li>";
	}
	html+="</ul></div></body></html>";
	return html;
}

-(CPArray)errors{
	return errors;
}

-(ManagedObjectContext)context
{
	return ctx;
}

- (id)initWithEntity:(CPString)e andContext:(ManagedObjectContext)c
{
	if(self = [super init])
	{
		entity=e;
		ctx=c;
		fields={};
	}
	return self;
}

-(id)valueForKey:(CPString)name
{
	if(name=="id"){
		return ident;
	}else{
		return fields[name];
	}
}

-(void)setValue:(id)val forKey:(CPString)name
{
	if(name!="id"){
		fields[name]=val;
	}
}

-(void)saveWithCallback:(Function)cb
{
	errors=[];
	if(ident){
		var body=JSON.stringify({
			model:fields
		});
		var op=objj_request_xmlhttp();
		op.open('put',ctx.root+entity+'/'+ident,true);
		op.setRequestHeader('Content-Type','application/json');
		op.setRequestHeader('Accept','application/json');
		op.onreadystatechange=function(){
			if(op.readyState==4){
				op.onreadystatechange=null;
				var obj=JSON.parse(op.responseText);
				if([obj isKindOfClass:CPArray]){
					errors=obj;
				}
				cb(!errors.length);
			}
		};
		op.send(body);
	}else{
		var body=JSON.stringify({
			model:fields
		});
		var op=objj_request_xmlhttp();
		op.open('post',ctx.root+entity,true);
		op.setRequestHeader('Content-Type','application/json');
		op.setRequestHeader('Accept','application/json');
		op.onreadystatechange=function(){
			if(op.readyState==4){
				op.onreadystatechange=null;
				var obj=JSON.parse(op.responseText);
				if(obj.id){
					ident=obj.id;
					cb(true);
				}else{
					errors=obj;
					cb(false);
				}
			}
		};
		op.send(body);
	}
}

-(void)destroyWithCallback:(Function)cb
{
	if(ident){
		var op=objj_request_xmlhttp();
		op.open('delete',ctx.root+entity+'/'+ident,true);
		op.setRequestHeader('Content-Type','application/json');
		op.setRequestHeader('Accept','application/json');
		op.onreadystatechange=function(){
			if(op.readyState==4){
				cb();
			}
		};
		op.send(null);
	}else{
		cb();
	}
}

-(CPString)entityForRelationship:(CPString)name
{
	return entity+'/'+ident+'/'+name;
}

@end
