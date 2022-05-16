/**
    @name: Ring.lsl
    @description:

    @author: Zai Dium
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

float  ring_total_time = 5;
integer ring_count = 5;
float ring_height = 0.5;

vector start_pos; //* starting pos
integer ring_number = 0; //* ring number
integer temp = 0; //* if enabled do not process teleports

string toRegion;
vector toPos;
vector toLookAt;
key agent;

sendCommandTo(key id, string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    if (id)
        llRegionSayTo(id, channel_number, cmd);
    else
        llRegionSay(channel_number, cmd);
}

sendCommand(string cmd, list params)
{
    sendCommandTo(NULL_KEY, cmd, params);
}

sendLocalCommand(string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    llSay(channel_number, cmd);
}

start()
{
    start_pos = llGetPos();
    llSleep(0.1);
    llSetPos(start_pos + <0, 0, ring_height>);
    llSleep(0.2);
    vector offset;
    offset = <0, 0, ring_height * (ring_count - llAbs(ring_number) + 1)>; //* +1 the initial pos
    llSetPos(start_pos + offset);
    llSleep(0.2);
}

finish() {
    llTriggerSound("e6a27da5-6eed-40e7-b57b-e99ac9eb42fe",1.0);
    llSetPos(start_pos);
    llSleep(0.2);
    llDie();
}

default
{
    on_rez(integer param)
    {
        llTriggerSound("e6a27da5-6eed-40e7-b57b-e99ac9eb42fe", 1.0);
        if (param != 0) {
            llSetObjectDesc((string)param); //* because not saved to `listen` scope :(
            //start();
            llResetScript();
            //llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
        }
    }

    state_entry()
    {
        llVolumeDetect(TRUE);

        ring_number = (integer)llGetObjectDesc();
        if (ring_number < 0) {
            ring_number = -ring_number; //* based on 1 not 0, zero make bug diveded
            temp = 1;
        }
        else
            temp = 0;

        //llOwnerSay("Entry Number: " + (string)ring_number);
        if (ring_number != 0) {
            if (channel_number == 0)
              channel_number = (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + channel_private_number;

            llListen(channel_number,"","","");
            start();
            if (temp != 0)
                llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
            else {
                sendLocalCommand("ready", [(string)ring_number]);
            }
        }
    }

    collision_start(integer num)
    {
        //llSay(0, llDetectedKey(0));
    }

    run_time_permissions(integer perm)
    {
        if(PERMISSION_TELEPORT & perm)
        {
            osTeleportAgent(agent, toPos, toLookAt);
        }
        finish();
    }

    listen (integer channel, string name, key id, string message)
    {
        if (channel == channel_number)
        {
            if (ring_number > 0)
            {
                list cmdList = llParseString2List(message,[";"],[""]);
                string cmd = llList2String(cmdList,0);
                cmdList = llDeleteSubList(cmdList, 0, 0);
                if (cmd == "teleport")
                {
                    if (temp == 0) {
                        integer number = llList2Integer(cmdList, 0);
                        if (number == ring_number) {
                            agent = llList2Key(cmdList, 4);
                            if (agent) {
                                llOwnerSay("teleport: " + (string)agent);
                                toRegion = llList2String(cmdList, 1);
                                toPos = llList2Vector(cmdList, 2 );
                                toLookAt = llList2Vector(cmdList, 3);
                                if (agent == llGetOwner()) {
                                    osTeleportAgent(agent, toPos, toLookAt);
                                    finish();
                                } else
                                    llRequestPermissions(agent, PERMISSION_TELEPORT);
                                //osTeleportAgent(agent, toPos, toLookAt);
                                //osTeleportAgent(agent, toRegion, toPos, toLookAt );
                            }
                            else
                                finish();
                        }
                    }
                }
            }
        }
    }

    timer()
    {
        llSetTimerEvent(0.0);
        finish();
    }
}
