list ignore 
=[
""
];
key group = "XXXX";
string encryption_password = "12";
integer Channel = 2;
default
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llRequestPermissions(llGetOwner(),PERMISSION_RETURN_OBJECTS);
    llSetLinkTextureAnim(LINK_THIS, ANIM_ON | LOOP, ALL_SIDES,4,2, 0, 64, 8 );
    }
    run_time_permissions(integer perm)
    {
        if (PERMISSION_RETURN_OBJECTS & perm)
        {  
        llListen(Channel,"","","");
        }
    }
    listen(integer c,string n, key i, string m)
    {
    if(llGetOwnerKey(i) == group)
    {  
        string decrypted = llBase64ToString(llXorBase64(m, llStringToBase64(encryption_password)));  
        list items = llParseString2List(decrypted, ["|"], []);
        if(llList2String(items,0) =="return_object_by_owner")
        {
          if (~llListFindList(ignore,[(string)llList2String(items,1)])){ llRegionSay(Channel,"safe_fail"); }else
          {
          llReturnObjectsByOwner(llList2Key(items,1), OBJECT_RETURN_REGION);
          }
        }
      }
    }
  }
