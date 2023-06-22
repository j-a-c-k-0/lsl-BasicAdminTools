integer footer_agent_display = 9;//limit 30
integer message_mode = 2;//1,2
string webhook_url = "";
list privacy_zone =[];//"vector=radius=title"

string color(string A)
{
if(A == "unknown_agent")return"16744448";
if(A == "known_agent")return"100000";
if(A == "alert")return"16711680";
return"16777215";
}
string A_status(key avatar)
{ 
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
return "standing";
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
send_message2(key AvatarID,string Message,string name,string description,string cho_color) 
{
list json =[
"username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,["color",color(cho_color),"title",name,
"description",description,"url","https://world.secondlife.com/resident/" + (string)AvatarID,
"author",llList2Json(JSON_OBJECT,["name",Message,"",""]),
"footer",llList2Json(JSON_OBJECT,["","","text",region_avatar_list()])])]),"",""];

llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
"application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
llSleep(.5);
}
send_message1(string Message)
{
llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
"application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,
["username",llGetRegionName()+"","content",Message]));
llSleep(.5);
}
default
{
    changed(integer change)
    {
    if (change & CHANGED_REGION_START){send_message1("Region_Restart : "+llGetDate()+"\n"+"Posted : <t:"+(string)llGetUnixTime()+":R>"); llResetScript();}
    }
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llSetObjectDesc("mode_"+(string)message_mode);
    llSetObjectName("["+llGetRegionName()+"]");
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    list target =llGetLinkPrimitiveParams(LINK_THIS,[PRIM_DESC]);
    if(llList2String(target,0) == "mode_1"){ send_message1(msg); }
    if(llList2String(target,0) == "mode_2")
    {
    list items = llParseString2List(msg, ["|"], []);
    send_message2(llList2Key(items,0),llList2String(items,1),llList2String(items,2),llList2String(items,3),llList2String(items,4)); 
} } }
