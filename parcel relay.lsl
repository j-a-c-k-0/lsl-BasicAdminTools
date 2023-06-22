list ignore =[];
key owner = "XXXX";
integer Channel = 678445;
default
{
    changed(integer change)
    {
      if (change & CHANGED_REGION_START)         
      {
      llResetScript();    
      }
    } 
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llListen(Channel,"","","");
    llSetLinkTextureAnim(LINK_THIS, ANIM_ON | LOOP, ALL_SIDES,4,2, 0, 64, 8 );
    }
    listen(integer c,string n, key i, string m)
    { 
    if(llGetOwnerKey(i)==owner)
    {  
      list items = llParseString2List(m, ["|"], []);
      if (~llListFindList(ignore,[(string)llList2String(items,1)])){ }else
      {
          if(llList2String(items,0) =="kick")
          {
          llTeleportAgentHome(llList2String(items,1));
          }
          if(llList2String(items,0) =="unbanned")
          {
          llRemoveFromLandBanList(llList2String(items,1));
          }
          if(llList2String(items,0) =="banned")
          {
          llTeleportAgentHome(llList2String(items,1));    
          llAddToLandBanList(llList2String(items,1),0);
          }
        }
      }
    }
  }
