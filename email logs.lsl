string Address = "XXXX";
integer logs_limit = 50;
integer D = 86400;
integer C = 43200;
integer H = 3600;
integer M = 60;
list logs;
string timeclock( integer vIntLocalOffset ){
  integer vIntBaseTime = ((integer)llGetGMTclock() + D + vIntLocalOffset * H) % D;
  string vStrReturn;
  if (vIntBaseTime < C)
  {
  vStrReturn = " AM";}else{vStrReturn = " PM"; vIntBaseTime = vIntBaseTime % C;
  }
  integer vIntMinutes = (vIntBaseTime % H) / M;
  vStrReturn = (string)vIntMinutes + vStrReturn;
  if (10 > vIntMinutes){vStrReturn = "0" + vStrReturn;
  }
  if (vIntBaseTime < H)
  {
  vStrReturn = "12:" + vStrReturn;}else{vStrReturn = (string)(vIntBaseTime / H) + ":" + vStrReturn;
  }return vStrReturn;
}
sendemail()
{
string region = llGetRegionName();
llEmail(Address,region+" "+"[ Time "+timeclock(-8)+" Date "+(string)llGetDate()+" ]",(string)logs);
llSleep(0.5);
logs = [];
}
default
{
    changed(integer change)
    {
      if (change & CHANGED_REGION_START)         
      {
      logs += "[ Region Restart ][ Time "+timeclock(-8)+" Date "+(string)llGetDate()+" ]"+"\n"; 
      }
    }
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    string region = llGetRegionName();
    llSetObjectName("["+region+"]");
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    integer length = llGetListLength(logs);
    if (length > logs_limit)
    {
    sendemail();
    logs += msg+"[ Time "+timeclock(-8)+" Date "+(string)llGetDate()+" ]"+"\n";
    }
    else
    {
    logs += msg+"[ Time "+timeclock(-8)+" Date "+(string)llGetDate()+" ]"+"\n";
    }
  }
}