string webhook_url = "";

integer flag = AGENT_LIST_REGION;
integer time_event = 3;
integer footer_agent_display = 20;
integer message_mode = 2;//1,2

list privacy_zone =[];//"vector=radius=title"
list known_list =[];

string A_status(key avatar)
{
//if(llGetAgentInfo(avatar) & AGENT_ON_OBJECT){list a = llGetObjectDetails(avatar,([OBJECT_ROOT]));return "sitting on "+llDeleteSubString(llKey2Name(llList2String(a,0)),25,1000000);}
if(llGetAgentInfo(avatar) & AGENT_ON_OBJECT) return "sitting on object";
if(llGetAgentInfo(avatar) & AGENT_AWAY) return "afk";
if(llGetAgentInfo(avatar) & AGENT_BUSY) return "busy";
if(llGetAgentInfo(avatar) & AGENT_CROUCHING) return "crouching";
if(llGetAgentInfo(avatar) & AGENT_FLYING) return "flying";
if(llGetAgentInfo(avatar) & AGENT_IN_AIR) return "in air";
if(llGetAgentInfo(avatar) & AGENT_MOUSELOOK) return "mouse look";
if(llGetAgentInfo(avatar) & AGENT_SITTING) return "sitting";
if(llGetAgentInfo(avatar) & AGENT_TYPING) return "typing";
if(llGetAgentInfo(avatar) & AGENT_WALKING) return "walking";     
if(llGetAgentInfo(avatar) & AGENT_ALWAYS_RUN) return "running";
if(llGetAgentInfo(avatar) & AGENT_AUTOMATED) return "bot";
return "standing";
}
string getTime(integer secs)
{
string timeStr; integer days; integer hours; integer minutes;
if (secs>=86400){days=llFloor(secs/86400);secs=secs%86400;timeStr+=(string)days+" day";if (days>1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=3600){hours=llFloor(secs/3600);secs=secs%3600;timeStr+=(string)hours+" hour";if(hours!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=60){minutes=llFloor(secs/60);secs=secs%60;timeStr+=(string)minutes+" minute";if(minutes!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if (secs>0){timeStr+=(string)secs+" second";if(secs!=1){timeStr+="s";}}return timeStr;
}
data_delete(string a)
{
   integer counter; integer x;
   integer Lengthx = llLinksetDataCountKeys();
   for ( ; x < Lengthx; x += 1)
   { 
   string b = llLinksetDataRead("data"+(string)x);
   if(a == "data"+(string)x){ }else{llLinksetDataWrite("temp"+(string)counter,b);counter = counter + 1;} 
   }   
   llLinksetDataDeleteFound("data",""); integer v; 
   integer Length = llLinksetDataCountKeys();
   for ( ; v < Length; v += 1)
   {
   string b = llLinksetDataRead("temp"+(string)v);
   llLinksetDataWrite("data"+(string)v,b);
   }  
   llLinksetDataDeleteFound("temp","");
}
string detect_bot(key avatar)
{
if(llGetAgentInfo(avatar) & AGENT_AUTOMATED){return "1";}
return "0";
}
integer data_check(string uuid)
{
   integer x;
   integer Length = llLinksetDataCountKeys();
   for ( ; x < Length; x += 1)
   { 
      string b = llLinksetDataRead("data"+(string)x);
      list items = llParseString2List(b,["|"],[]);
      if(b == ""){data_delete("data"+(string)x);}else
      {
         if(uuid == llList2String(items,3))
         { 
         list details = llGetObjectDetails(uuid,([OBJECT_NAME,OBJECT_POS]));
         vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
         string position = "("+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c)+")";
         llLinksetDataWrite("data"+(string)x,llList2String(items,0)+"|"+position+"|"+detect_bot(uuid)+"|"+uuid+"|"+llList2String(items,4));
         return 1;
         }
      }
   }return 0;
}
agententer()
{
  list List = llGetAgentList(flag,[]);
  integer Length = llGetListLength(List);
  if (!Length){return;}else{integer x;for ( ; x < Length; x += 1)
  {
      list details = llGetObjectDetails(llList2String(List,x),([OBJECT_NAME,OBJECT_POS]));
      vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
      string position = "("+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c)+")";
      if (data_check(llList2String(List,x)) == 0)
      {
      string Name = llDeleteSubString(llList2String(details,0),30,1000000);
      string Data = Name+"|"+position+"|"+detect_bot(llList2String(List,x))+"|"+llList2String(List,x)+"|"+(string)llGetUnixTime();
      visit_logs_send(Data,1); llLinksetDataWrite("data"+(string)llLinksetDataCountKeys(),Data);
      }
    }
  }
}
agentleft()
{
  integer x;
  integer Length = llLinksetDataCountKeys();
  for ( ; x < Length; x += 1)
  { 
    string b = llLinksetDataRead("data"+(string)x);
    list items = llParseString2List(b,["|"],[]);
    if(b == ""){data_delete("data"+(string)x);}else
    {
      vector agent = llGetAgentSize(llList2String(items,3));
      if(agent){ }else
      {  
      integer time = (integer)llGetUnixTime() - llList2Integer(items,4);
      string Data = llList2String(items,0)+"|"+llList2String(items,1)+"|"+llList2String(items,2)+"|"+llList2String(items,3)+"|"+(string)time;
      visit_logs_send(Data,2); data_delete("data"+(string)x);
      }
    }
  }
}
string p_zone(string position,key ID)
{
  vector ovF = (vector)position; float a = ovF.x; float b = ovF.y; float c = ovF.z;
  string position_A = (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c);
  integer Length = llGetListLength(privacy_zone);     
  if (!Length){ return position_A+" | "+A_status(ID); }else
  {
  integer x;
  for ( ; x < Length; x += 1)
  {
    list items = llParseString2List(llList2String(privacy_zone, x),["="],[]);
    float dist = llVecDist((vector)position,(vector)llList2String(items,0));
    if(dist>llList2Integer(items,1)){ }else
    {
    return llList2String(items,2);
} } } return position_A+" | "+A_status(ID); }
string region_avatar_list() 
{
   list List = llGetAgentList(AGENT_LIST_REGION,[]);
   integer Length = llGetListLength(List);
   list detect_list = [];
   if (!Length){ return "No One Detected"; }else
   {
      integer x;
      for ( ; x < Length; x += 1)
      {
         integer count = llGetListLength(detect_list);
         if (count > footer_agent_display) 
         {
         detect_list += "..."+"\n";
         return "Agent : "+(string)Length+"\n"+(string)detect_list;
         }else{
         list details = llGetObjectDetails(llList2Key(List, x), ([OBJECT_NAME,OBJECT_POS]));
         detect_list += llDeleteSubString(llList2String(details,0),25,1000000)+" ( "+p_zone((string)llList2Vector(details,1),llList2Key(List, x))+" )"+"\n";
} } }return "Agent : "+(string)Length+"\n"+(string)detect_list; }
string agent(string A){if(~llListFindList(known_list,[A])){return"100000";}return"16744448";}
string bot(string A){if(A=="1"){return"🤖 ";}return"";}
visit_logs_send(string msg,integer mode) 
{
    list items = llParseString2List(msg, ["|"], []);
    string detail0 = ""; 
    string detail1 = "";

    if(mode == 1)
    {
    detail0 = "Uuid : "+llList2String(items,3)+"\n"+"Spawn Position : "+llList2String(items,1);
    detail1 = "has entered the sim";
    }
    if(mode == 2)
    {
    detail0 = "Uuid : "+llList2String(items,3)+"\n"+"Spawn Position : "+llList2String(items,1)+"\n"+"Visit Time : "+getTime((integer)llList2String(items,4));
    detail1 = "has left the sim";
    }
    list json =[
    "username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,[
    "color",agent(llList2String(items,3)),"title",bot(llList2String(items,2))+llList2String(items,0),
    "description",detail0+"\nPosted : <t:"+(string)llGetUnixTime()+":R>","url","https://world.secondlife.com/resident/"+llList2String(items,3),
    "author",llList2Json(JSON_OBJECT,["name",detail1]),
    "footer",llList2Json(JSON_OBJECT,["text",region_avatar_list()])])])];

    llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
    "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
    HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
    llSleep(.5);
}
alert_log(string Message)
{
    list json =[
    "username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,[
    "color","16711680","title",Message,"description","Posted : <t:"+(string)llGetUnixTime()+":R>","url",""])])];

    llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
    "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
    HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
    llSleep(.5);
}
default
{
    changed(integer change)
    {
    if (change & CHANGED_REGION_START){alert_log("Region_Restart : "+llGetDate()); llResetScript();}
    }
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llLinksetDataReset();    
    llSetTimerEvent(time_event);
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    if(num == 5){alert_log(msg);}
    }
    timer()
    {
    agententer(); 
    agentleft();
    }
  }
