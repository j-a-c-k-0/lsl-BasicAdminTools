integer flag = AGENT_LIST_REGION;
integer time_event = 3;
list send_message_list =[];
list known_list =[];
list data;

string getTime(integer secs)
{
string timeStr; integer days; integer hours; integer minutes;
if (secs>=86400){days=llFloor(secs/86400);secs=secs%86400;timeStr+=(string)days+" day";if (days>1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=3600){hours=llFloor(secs/3600);secs=secs%3600;timeStr+=(string)hours+" hour";if(hours!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=60){minutes=llFloor(secs/60);secs=secs%60;timeStr+=(string)minutes+" minute";if(minutes!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if (secs>0){timeStr+=(string)secs+" second";if(secs!=1){timeStr+="s";}}return timeStr;
}
string agent(string A)
{
if (~llListFindList(known_list,[A]))return"known_agent";  
return"unknown_agent";
}
send_message(string message) 
{
 integer Length = llGetListLength(send_message_list);
 if (!Length){return;}else{integer x; for ( ; x < Length; x += 1)
 {
    if((key)llList2String(send_message_list, x)){if(llGetAgentSize(llList2String(send_message_list,x)))
    {
    llRegionSayTo(llList2String(send_message_list,x),0,message);
}}}}}
integer data_check(string analyze)
{
integer x; integer Length = llGetListLength(data); 
for ( ; x < Length; x += 1){integer search_found = ~llSubStringIndex(llList2String(data,x),analyze);if (search_found){return 0;}}return 1;
}
agententer() 
{
    list List = llGetAgentList(flag,[]);
    integer Length = llGetListLength(List);     
    if (!Length){return;}else{integer x;for ( ; x < Length; x += 1)
    {
            if(data_check(llList2String(List,x)) == 1)
            {
            send_message("secondlife:///app/agent/"+llList2String(List,x)+"/about"+" has entered the sim");    
            list details = llGetObjectDetails(llList2String(List, x),([OBJECT_NAME,OBJECT_POS]));
            vector ovF = llList2Vector(details, 1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
            string position = "("+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c)+")";

            list target =llGetLinkPrimitiveParams(2,[PRIM_DESC]);
            if(llList2String(target,0) == "mode_2")
            {
            llMessageLinked(2, 0,
            llList2String(List, x)+"|"+
            "has entered the sim"+"|"+
            llDeleteSubString(llList2String(details,0),30,1000000)+"|"+
            "Uuid : "+llList2String(List,x)+"\n"+
            "Spawn Position : "+position+"\n"+
            "Posted : <t:"+(string)llGetUnixTime()+":R>"+"|"+
            agent(llList2String(List,x)),"");
            }
            data += llList2String(List,x)+"|"+llDeleteSubString(llList2String(details,0),30,1000000)+"|"+(string)llGetUnixTime()+"|"+position;
}   }   }   }
agentleft()
{
    integer Length= llGetListLength(data);
    if (!Length){return;}else{integer x;for ( ; x < Length; x += 1)
    {
        list items = llParseString2List(llList2String(data,x),["|"], []);
        if((key)llList2String(items,0))
        {
            vector agent = llGetAgentSize(llList2String(items,0));
            if(agent){ }else
            {
            send_message("secondlife:///app/agent/"+llList2String(items,0)+"/about"+" has left the sim");
            integer time = (integer)llGetUnixTime() - llList2Integer(items,2);

            llMessageLinked(3, 0,"[ Name "+llList2String(items,1)+" ]"+"[ Uuid "+llList2String(items,0)+" ]"+"[ Visit Time "+getTime(time)+" ]","");

            list target =llGetLinkPrimitiveParams(2,[PRIM_DESC]);
            if(llList2String(target,0) == "mode_1")
            {
            llMessageLinked(2, 0,
            "Name : "+llList2String(items,1)+"\n"+
            "Uuid : "+llList2String(items,0)+"\n"+
            "Spawn Position : "+llList2String(items,3)+"\n"+
            "Visit Time : "+getTime(time)+"\n"+
            "Posted : <t:"+(string)llGetUnixTime()+":R>","");
            }
            if(llList2String(target,0) == "mode_2")
            {
            llMessageLinked(2, 0,
            llList2String(items,0)+"|"+
            "has left the sim"+"|"+
            llList2String(items,1)+"|"+
            "Uuid : "+llList2String(items,0)+"\n"+
            "Visit Time : "+getTime(time)+"\n"+
            "Posted : <t:"+(string)llGetUnixTime()+":R>"+"|"+
            agent(llList2String(items,0)),"");
            }
            integer r = llListFindList(data,[llList2String(data,x)]);
            data = llDeleteSubList(data,r,r);
}  }  }  }  }
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
    state_entry()
    {
    llSetLinkTextureAnim(LINK_THIS, ANIM_ON | LOOP, ALL_SIDES,4,2, 0, 64, 8 );
    llSetObjectName("["+llGetRegionName()+"]");
    llSetTimerEvent(time_event);
    }
    timer()
    {
    agententer(); 
    agentleft();
  } }
