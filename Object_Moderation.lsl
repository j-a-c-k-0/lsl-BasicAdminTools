string WEBHOOK_URL = "XXXX";
integer webhook_message = FALSE;
integer message_mode = 2;

message_mode1(string Message)
{
key http_request_id = llHTTPRequest(WEBHOOK_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
"application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,
["username",llGetRegionName()+"","content",Message]));
}
message_mode2(key AvatarID,string Message,string name,string description) 
{
list json =[
"username",llGetRegionName()+"","embeds", llList2Json(JSON_ARRAY,[
llList2Json(JSON_OBJECT,["color","16711680","title",name,
"description",description,"url","https://world.secondlife.com/resident/" + (string)AvatarID,
"author",llList2Json(JSON_OBJECT,["name",Message,"",""]),
"footer",llList2Json(JSON_OBJECT,["",""])])]),"",""];
key http_request_id = llHTTPRequest(WEBHOOK_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
"application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
}
Message(string id,integer count,string name) 
{
  if(webhook_message == FALSE) { return; }
  if(message_mode == 1)
  {
  message_mode1("Name : "+name+"\n"+"Uuid : "+id+"\n"+"HighRezzCount : "+(string)count+"\n"+"Posted : <t:"+(string)llGetUnixTime()+":R>");
  }
  if(message_mode == 2)
  {
  message_mode2(id,"HIGH REZZ_COUNT > "+(string)count,name,"Uuid : "+id+"\n"+"Posted : <t:"+(string)llGetUnixTime()+":R>"); 
} }
default
{
    changed(integer change)
    {
    if (change & CHANGED_REGION_START){llResetScript();}
    } 
    on_rez(integer start_param)
    {
    llResetScript();
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    list items = llParseString2List(msg, ["|"], []);
    Message(llList2Key(items,0),llList2Integer(items,1),llList2String(items,2));
  } }



>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



list users = [""];
list temp_whitelist;
list whitelist;
list cache0;
list cache1;

integer dialog_channel = 1;
integer rely_channel = 2;
string encryption_password = "12";
key owner = "XXXX";

integer rezzwarning = 800;
integer rezzlimit = 1500;
float banned_time_hour = 1.0;

integer safe_fail_trigger = TRUE;
integer dialog_option = FALSE;
integer event_time = 3;
integer notecardLine;
integer chanhandlr;
string notecardName = "whitelist";
string ReturnObjectByAgentAbsence;
string ReturnObjectByRezzCount;
string error_message;
string memory_result;
key notecardQueryId;
key notecardKey;

status_startup()
{
list target0 =llGetLinkPrimitiveParams(2,[PRIM_DESC]);
if("1"== llList2String(target0,0)){ ReturnObjectByAgentAbsence = "active"; }else{ ReturnObjectByAgentAbsence = "deactivate";}
list target1 =llGetLinkPrimitiveParams(3,[PRIM_DESC]);
if("1"== llList2String(target1,0)) { ReturnObjectByRezzCount = "active"; }else{ ReturnObjectByRezzCount = "deactivate"; }
}
ReadNotecard()
{
    if (llGetInventoryKey(notecardName) == NULL_KEY)
    {
    llSetTimerEvent(0);   
    safe_fail_trigger = TRUE;
    error_message = "notecard_exception";     
    llSetText("Notecard '" + notecardName + "' missing or unwritten.",<1,0,0>,1);
    llSetLinkPrimitiveParamsFast(2,[PRIM_DESC,"0"]); llSetLinkPrimitiveParamsFast(3,[PRIM_DESC,"0"]);
    return;
    }
    else if (llGetInventoryKey(notecardName) == notecardKey) return;
    notecardKey = llGetInventoryKey(notecardName);
    notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
    llSetText("reading notecard...",<1,0,1>,1);
}
random_channel() 
{
dialog_channel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr);
chanhandlr = llListen(dialog_channel, "", NULL_KEY, "");
}
show_dialog(key id)
{
random_channel();
dialog_option = FALSE; 
llDialog(id,"memory : "+memory_result+"\n\n"+"[1] ReturnObjectByAgentAbsence Status : " + ReturnObjectByAgentAbsence
+"\n"+"[2] ReturnObjectByRezzCount Status : " + ReturnObjectByRezzCount
,["erase-temp","[2] on/off","add-temp","close","[1] on/off","option"], dialog_channel);
llSleep(.2);
}
show_dialog_option(key id)
{
random_channel();
dialog_option = TRUE;
llDialog(id,"\n"+"temp_white_list : "+(string)llGetListLength(temp_whitelist)+"\n"+
"white_list : "+(string)llGetListLength(whitelist)+"\n"+
"cache_list : "+(string)(llGetListLength(cache0)+llGetListLength(cache1))
,["return-object","reset-script","menu","erase-cache"], dialog_channel);
llSleep(.2);
}
string get_username(key id)
{
vector agent = llGetAgentSize(id);
if(agent){ return llDeleteSubString(llKey2Name(id),30,1000000); }else{ return id;}
}
rezz_limiter(key id,integer count,string crypt)
{ 
  if(count> rezzwarning && (integer)count< rezzlimit )
  {
  llRegionSay(rely_channel,crypt); 
  llInstantMessage(id,"Warning Don't go rezz over "+(string)rezzwarning);
  }
  if((integer)count> rezzlimit)
  {
  string name = get_username(id);      
  llRegionSay(rely_channel,crypt);
  llInstantMessage(id,"You had been banned for "+(string)((integer)banned_time_hour)+" hour Reason [ Rezzcount > "+(string)count+" ]");
  llTeleportAgentHome(id);
  llAddToLandBanList(id,banned_time_hour);
  llMessageLinked(LINK_THIS, 0,(string)id+"|"+(string)count+"|"+name,"");
} }
rezzcount_check0 (key id,integer value)
{
integer Length = llGetListLength(cache0);
if (!Length){return;}else{ integer x;for ( ; x < Length; x += 1)
{
    list items = llParseString2List(llList2String(cache0,x), ["|"], []);
    if(id == llList2String(items,0)){if(value == llList2Integer(items,1)){ }else
    {
    integer r = llListFindList(cache0,[llList2String(cache0,x)]); 
    cache0 = llDeleteSubList(cache0,r,r);
}}}}}
rezzcount_check1 (key id,integer value)
{
integer Length = llGetListLength(cache1);
if (!Length){return;}else{integer x;for ( ; x < Length; x += 1)
{
    list items = llParseString2List(llList2String(cache1,x), ["|"], []);
    if(id == llList2String(items,0)){if(value == llList2Integer(items,1)){ }else
    {
    integer r = llListFindList(cache1,[llList2String(cache1,x)]); 
    cache1 = llDeleteSubList(cache1,r,r);
}}}}}
delete_data0(list TempList)
{
  integer Lengthx = llGetListLength(cache0);
  if (!Lengthx){return;}else{ integer x; for ( ; x < Lengthx; x += 1)
  {
   list items = llParseString2List(llList2String(cache0,x),["|"],[]); if (~llListFindList(TempList,[llList2Key(items,0)])){ }else
   {
   integer r = llListFindList(cache0,[llList2String(cache0,x)]);
   cache0 = llDeleteSubList(cache0,r,r);
}}}}
delete_data1(list TempList)
{
  integer Lengthx = llGetListLength(cache1);
  if (!Lengthx){return;}else{ integer x; for ( ; x < Lengthx; x += 1)
  {
   list items = llParseString2List(llList2String(cache1,x),["|"],[]); if (~llListFindList(TempList,[llList2Key(items,0)])){ }else
   {
   integer r = llListFindList(cache1,[llList2String(cache1,x)]);
   cache1 = llDeleteSubList(cache1,r,r);
}}}}
Object_Moderation() 
{    
  list TempList = llGetParcelPrimOwners(llGetPos());
  integer Length = llGetListLength(TempList);
  delete_data0(TempList); delete_data1(TempList);
  if (!Length){return;}else{ integer z; for ( ; z < Length; z += 2)
  {
      if (~llListFindList(whitelist,[llList2String(TempList, z)])){ }else
      {
        if (~llListFindList(temp_whitelist,[llList2String(TempList, z)])){ }else
        {
          string crypt = llXorBase64(llStringToBase64("return_object_by_owner"+"|"+llList2String(TempList, z)),llStringToBase64(encryption_password)); 
          if(ReturnObjectByRezzCount == "active")
          {
             rezzcount_check0(llList2Key(TempList,z),llList2Integer(TempList,z+1));
             if (~llListFindList(cache0,[llList2String(TempList,z)+"|"+llList2String(TempList,z+1)])){ }else
             {
             cache0 += llList2String(TempList,z)+"|"+llList2String(TempList,z+1);
             rezz_limiter(llList2Key(TempList,z),llList2Integer(TempList,z+1),crypt);
             }
          }
          vector agent = llGetAgentSize(llList2String(TempList,z));
          if(agent){ }else
          {
            if(ReturnObjectByAgentAbsence == "active")
            {
              rezzcount_check1(llList2Key(TempList,z),llList2Integer(TempList,z+1));
              if (~llListFindList(cache1,[llList2String(TempList,z)+"|"+llList2String(TempList,z+1)])){ }else
              {  
              cache1 += llList2String(TempList,z)+"|"+llList2String(TempList,z+1);
              llRegionSay(rely_channel,crypt);
} } } } } } } }
default
{
  changed(integer change)
  {
    if (change & CHANGED_REGION_START)
    {
    temp_whitelist = []; cache0 = []; cache1 = [];
    return;
    }
  }
  on_rez(integer start_param) 
  {
  llResetScript();
  }
  state_entry()
  {
  llSetText("",<0,0,0>,0);
  ReadNotecard();
  }
  touch_start(integer num_detected)
  {
    if (~llListFindList(users,[(string)llDetectedKey(0)])){ if(safe_fail_trigger == FALSE) 
    {
    show_dialog(llDetectedKey(0)); return;
    }
    else
    {
    random_channel(); llDialog(llDetectedKey(0),"\n"+error_message+"\n",["restart"], dialog_channel); llSleep(.2); return; }
    }
  }
  listen(integer channel, string name, key id, string message)
  {
  if(safe_fail_trigger == TRUE) { if (~llListFindList(users,[(string)id])){ if(message == "restart"){ llResetScript(); } } }
  if(safe_fail_trigger == FALSE) 
  {
      if(llGetOwnerKey(id)==owner){ if(message == "safe_fail")
      { 
      llSetTimerEvent(0);
      safe_fail_trigger = TRUE;
      error_message ="safe_fail_trigger";
      llSetText("safe_fail_trigger",<1,0,0>,1);
      llSetLinkPrimitiveParamsFast(2,[PRIM_DESC,"0"]); llSetLinkPrimitiveParamsFast(3,[PRIM_DESC,"0"]);
      return;
      }
  }
  if (~llListFindList(users,[(string)id]))
  {
    if(message == "menu"){ show_dialog(id); return; } 
    if(message == "close"){ dialog_option = FALSE; return; }
    if(dialog_option == TRUE) 
    {
        if(message == "erase-cache")
        {
        llRegionSayTo(id,0,"cache cleared.");
        cache0 = []; cache1 = [];
        show_dialog_option(id);
        return;
        }
        if(message == "reset-script")
        {
        llResetScript();
        }
        if(message == "return-object")
        {
        llTextBox(id, "Please insert a uuid."+"\n"+"\n"+
        "Warning you're trying to return objects.", dialog_channel);
        return;
        }
        if((key)message)
        {
            if (!~llListFindList(whitelist, [message]))
            {
            llRegionSayTo(id,0,"secondlife:///app/agent/"+message+"/about"+" object returned");
            string crypt = llXorBase64(llStringToBase64("return_object_by_owner"+"|"+message),llStringToBase64(encryption_password));
            llRegionSay(rely_channel,crypt);
            show_dialog_option(id);
            return;
            }
            else
            {
            llTextBox(id,"\n"+"\n"+"could not return object.", dialog_channel);
            return;
            }
          }
          else
          {
          llTextBox(id,"\n"+"\n"+"invalid uuid.", dialog_channel);
          return;
          }
      }
      if(dialog_option == FALSE) 
      {
        if(message == "option")
        {
        show_dialog_option(id);
        return;
        }
        if(message == "[1] on/off")
        {
          if(ReturnObjectByAgentAbsence == "deactivate")
          {
          llSetLinkPrimitiveParamsFast(2,[PRIM_DESC,"1"]);
          ReturnObjectByAgentAbsence = "active";
          }
          else
          {
          llSetLinkPrimitiveParamsFast(2,[PRIM_DESC,"0"]);
          ReturnObjectByAgentAbsence = "deactivate";
          }
          show_dialog(id); cache1 = [];
          return;
        }
        if(message == "[2] on/off")
        {
          if(ReturnObjectByRezzCount == "deactivate")
          {
          llSetLinkPrimitiveParamsFast(3,[PRIM_DESC,"1"]);
          ReturnObjectByRezzCount = "active";
          }
          else
          {
          llSetLinkPrimitiveParamsFast(3,[PRIM_DESC,"0"]);   
          ReturnObjectByRezzCount = "deactivate";
          }
          show_dialog(id); cache0 = [];
          return;
        } 
        if(message == "add-temp")
        {
        llTextBox(id, "Please insert a uuid to be added."+"\n"+"\n"+
        "please be aware this is only temporary.", dialog_channel);
        return;
        } 
        if(message == "erase-temp")
        {
        llRegionSayTo(id,0,"cleared temporarily list.");   
        temp_whitelist = [];
        show_dialog(id); 
        return;
        }
        if((key)message)
        {
           if (!~llListFindList(temp_whitelist, [message]))
           {
           llRegionSayTo(id,0,"secondlife:///app/agent/"+message+"/about"+" temp add");
           temp_whitelist += message; 
           show_dialog(id);
           return;
           }
           else
           {
           llTextBox(id,"\n"+"\n"+"uuid already existed.", dialog_channel);
           return;
           }
         }
         else
         {
         llTextBox(id,"\n"+"\n"+"invalid uuid.", dialog_channel);
         return;
 } } } } }
 dataserver(key query_id, string data)
 {
   if (query_id == notecardQueryId){ if (data == EOF)
   {
        llSetText("",<0,0,0>,0);  
        memory_result =(string)llGetFreeMemory();    
        llListen(rely_channel,"","","");
        llSetTimerEvent(event_time); 
        safe_fail_trigger = FALSE;
        status_startup();
        }
        else
        {
             list params = llParseString2List(data, ["="], []);
             if((key)llList2String(params, 0))
             {
             whitelist += llList2String(params, 0); ++notecardLine;
             notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
             }
             else
             {
             llSetTimerEvent(0);
             safe_fail_trigger = TRUE;
             error_message ="invalid_uuid_configuration";
             llSetText("Invalid uuid list "+(string)(1+notecardLine)+" = "+llList2String(params, 0),<1,0,0>,1);
             llSetLinkPrimitiveParamsFast(2,[PRIM_DESC,"0"]); llSetLinkPrimitiveParamsFast(3,[PRIM_DESC,"0"]);
             return;
    }  }  }  }
    timer()
    {   
    if(safe_fail_trigger == FALSE) 
    {
    memory_result =(string)llGetFreeMemory();
    Object_Moderation();
} } }
