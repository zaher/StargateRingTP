/**
    @name: Gate.lsl
    @description:

    @author: Zai Dium
    @owner: Zai Dium
    @update: 2022-02-16
    @revision: 0.1
    @localcopy: ""
    @license: ?

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
integer owner_only = TRUE;
integer channel_number = 0; //* Set it to 0 to autogenerate it
integer channel_private_number = 1;

//*

integer glow_face = 2;
integer ring_count = 5; //* amount of rings to rez and teleport
float ring_total_time = 5;
float sensor_range = 2;
string ring_start_sound = "289b4a8d-5a9a-4cc3-8077-3d3e5b08bb8c";
key ring_sound = ""; //* UUID of ring sound

list cmd_list = [ "<--", "Refresh", "-->" ]; //* general navigation

list gates_name_list = []; //* gate rings list
list gates_id_list = []; //* gate rings keys list
list avatars_list = []; //* hold temp list of avatar keys for teleporting
key ring_recv_id; //* selected dest object ID
integer temp;

integer dialog_channel;
integer dialog_listen_id; //* dynamicly generated menu channel
integer cur_page; //* current menu page

listList(list l)
{
    integer len = llGetListLength(l);
    integer i;
    for( i = 0; i < len; i++ )
    {
        llOwnerSay((string)i + ": " +llList2String(l, i));
    }
    llOwnerSay("Total = " + (string)len);
}

list getCommands(integer page)
{
    llOwnerSay("page " + (string)page);
    listList(gates_name_list);
    integer length = llGetListLength(gates_name_list);
    if (length >= 9)
    {
        integer x = page * 9;
        return cmd_list + llList2List(gates_name_list, x , x + 8);
    }
    else {
        return cmd_list + gates_name_list;
    }
}

showDialog(key toucher_id) {
    llDialog(toucher_id, "Ring Gate", getCommands(cur_page), dialog_channel);
    llListenRemove(dialog_listen_id);
    dialog_listen_id = llListen(dialog_channel, "", toucher_id, "");
}

sendCommand(string cmd, string params) {
    if (params != "")
        cmd = cmd + ";" + params;
    llRegionSay(channel_number, cmd);
}

addGate(key id)
{
    if (llListFindList(gates_id_list,[id]) == -1)
    {
        gates_id_list += id; //* add ring to list
        string name = llList2String(llGetObjectDetails(id,[OBJECT_DESC]), 0);
        if (name == "")
            name = llList2String(llGetObjectDetails(id,[OBJECT_NAME]), 0);
        if (name == "")
            llOwnerSay("This id have no name: " + (string)id);
        llOwnerSay("add: " + name);
        gates_name_list += name;
    }
}

removeGate(key id){
    if (llListFindList(gates_id_list,[ id ]) == -1)
    {
        list tempList;
        integer index = llListFindList(avatars_list,[id]);
        if (index != -1)
        {
            tempList = llDeleteSubList(avatars_list,index,index);
        }
        avatars_list = tempList;
    }
}

start()
{
    llTriggerSound(ring_start_sound,1.0);
    vector pos = llGetPos() - <0,0,0.1>;
    integer ringNumber;
    for (ringNumber = 1; ringNumber <= ring_count; ringNumber++) {
        llSleep(ring_total_time / 10);
        integer n;
        if (temp)
            n = -ringNumber;
        else
            n = ringNumber;
        llRezObject("ring", pos, ZERO_VECTOR, ZERO_ROTATION, n);
    }
}

finish()
{
    llSetLinkAlpha(2,1.0,ALL_SIDES); //* show main ring base
    llSetPrimitiveParams([PRIM_GLOW, glow_face, 0.00, PRIM_FULLBRIGHT, glow_face, FALSE]); //* deactivate glow
    ring_recv_id = NULL_KEY;
    avatars_list = [];
}

teleport(vector dest)
{
    temp = 0; //not temp

    llRegionSayTo(ring_recv_id, channel_number, "activate"); //* send mesage to incoming
    //llSleep(ring_total_time / 5);

    dest = dest + <0,0,0.8>;
    integer i;
    integer c = llGetListLength(avatars_list);
    if (c > ring_count)
        c = ring_count;

    for(i=0; i < c; i++)
    {
        string agent = llStringTrim(llList2String(avatars_list, i), STRING_TRIM_HEAD);
        llSay(0, "teleporting: " + (string)agent);
        llSay(channel_number, "teleport:" + (string)(i+1) + ";"+llGetRegionName() + ";" + (string)dest + ";<1,1,1>;" + agent); //* send mesage to incoming
    }
}

clear(){
    gates_id_list = [];
    gates_name_list = [];
}

default
{
    changed (integer change)
    {
        if (change & CHANGED_OWNER) {
            llResetScript();
        }
    }

    collision_start(integer num)
    {
/*        key tempKey = llDetectedKey(0);
        avatars_list += tempKey;*/

/*        list tempList = llGetObjectDetails(tempKey,[OBJECT_CREATOR]); idk
        if (llList2Key(tempList,0) == NULL_KEY) {
            avatars_list += tempKey;
            llSay(0, "added:" + (string)tempKey);
        }
        */
    }

    collision_end(integer num)
    {
/*        if (!ring_recv_id) {
            list avList; //* hold list of AVs detected
            string tempKey = (string)llDetectedKey(0);
            integer index = llListFindList(avatars_list,[tempKey]);
            if (index != -1)
            {
                avList = llDeleteSubList(avatars_list,index,index);
            }
            avatars_list = avList;
        } */
    }

    state_entry()
    {
        if (channel_number == 0)
          channel_number = (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + channel_private_number;
        dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
        llListen(channel_number,"","","");

        clear();
        llSay(channel_number, "update");
    }

    state_exit()
    {
        llSay(channel_number, "remove");
    }

    touch_start(integer num_detected)
    {
        llSay(channel_number, "update");
        showDialog(llDetectedKey(0));
    }

    sensor( integer number_detected )
    {
        integer i;
        avatars_list = [];
        for( i = 0; i < number_detected; i++ ){
            key k = llDetectedKey(i);
            avatars_list += (string)k;
        }
        teleport(llList2Vector(llGetObjectDetails(ring_recv_id, [OBJECT_POS]), 0));
        //finish();
    }

    no_sensor(){
       finish();
    }

    timer()
    {
        llSetTimerEvent(0);
        finish();
    }

    listen (integer channel, string name, key id, string message)
    {
        if (channel == channel_number)
        {
            list cmdList = llParseString2List(message,[";"],[""]);
            string cmd = llList2String(cmdList,0);
            cmdList = llDeleteSubList(cmdList, 0, 0);

            if (cmd == "update") {
                addGate(id);
                llSay(channel_number, "add"); //* send pong reply (ring sync)
            }
            else if (message == "add")
            {
                addGate(id);
            }
            else if (message == "remove")
            {
                removeGate(id);
            }
            else if (cmd == "activate")
            {
                if (id != llGetKey())
                { //*not self s
                    ring_recv_id = NULL_KEY;
                    llSetLinkAlpha(2,0.0,ALL_SIDES); //* hide main ring base
                    llSetPrimitiveParams([PRIM_GLOW, glow_face, 0.20, PRIM_FULLBRIGHT, glow_face, TRUE]); //* glow face
                    llTriggerSound(ring_sound, 1.0);
                    temp = 1;
                    start();
                    llSetTimerEvent(ring_total_time);
                }
            }
        }
        else //* Dialog
        {
            llListenRemove(dialog_listen_id);
            integer button_index = llListFindList(gates_name_list, [message]);

            if (message == "<--")
            {
                if (cur_page > 0)
                    cur_page -= 1;
                showDialog(id);
            }
            else if (message == "-->")
            {
                integer max_limit = llGetListLength(gates_name_list) / 9;
                if (max_limit >= 1 && cur_page <= max_limit)
                    cur_page += 1;
                showDialog(id);
            }
            else if (message == "Refresh") {
                clear();
                llSay(channel_number, "update");
                finish();
            }
            else if (button_index != -1)
            {
                ring_recv_id = (key)llList2String(gates_id_list, button_index); //* id of destination
                llSetLinkAlpha(2,0.0,ALL_SIDES); //* hide main ring base
                llSetPrimitiveParams([PRIM_GLOW, glow_face, 0.20, PRIM_FULLBRIGHT, glow_face, TRUE]); //* activate glow
                llTriggerSound(ring_sound, 1.0);
                temp = 0;
                start();
                llSleep(ring_total_time / 2);
                llSensor("", NULL_KEY, AGENT, sensor_range, PI);
                llSetTimerEvent(ring_total_time);
           }
        }
    }
}
