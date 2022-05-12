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
integer is_temp = 0; //* if enabled do not process teleports

default
{
    on_rez(integer param)
    {
        llTriggerSound("e6a27da5-6eed-40e7-b57b-e99ac9eb42fe", 1.0);
        if (param < 0) {
            ring_number = -param; //* based on 1 not 0, zero make bug diveded
            is_temp = 1;
        }
        else {
            ring_number = param; //* based on 1 not 0, zero make bug diveded
            is_temp = 0;
        }
        if (ring_number != 0) {
            llSetObjectDesc((string)param); //* because ring_number not saved to `listen` scope :(
            start_pos = llGetPos();
            llSleep(0.1);
            llSetPos(start_pos + <0, 0, ring_height>);
            llSleep(0.2);
            vector offset;
            offset = <0, 0, ring_height * (ring_count - ring_number + 1)>; //* +1 the initial pos
            llSetPos(start_pos + offset);
            state ring;
        }
    }
}

state ring
{
    timer()
    {
        llSetTimerEvent(0.0);
        llTriggerSound("e6a27da5-6eed-40e7-b57b-e99ac9eb42fe",1.0);
        llSetPos(start_pos);
        llSleep(0.2);
        llDie();
    }

    state_entry()
    {
        if (channel_number == 0)
          channel_number = (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + channel_private_number;
        llListen(channel_number,"","","");
        llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
    }

    listen (integer channel, string name, key id, string message)
    {
        llSay(0, "listen.ring_number: " + (string)ring_number);
        if (channel == channel_number)
        {

            list cmdList = llParseString2List(message,[";"],[""]);
            string cmd = llList2String(cmdList,0);
            cmdList = llDeleteSubList(cmdList, 0, 0);
            if (cmd == "reset")
            {
                llResetScript();
            }
            else if (cmd == "teleport")
            {
                if (is_temp > 0) {
                    integer number = llList2Integer(cmdList, 0);
                    if (number == ring_number) {
                        string toRegion = llList2String(cmdList, 1 );
                        vector toPos = llList2Vector(cmdList, 2 );
                        vector toLookat = llList2Vector(cmdList, 3);
                        key k = llList2Key(cmdList, 4);
                        llSay(0, "teleport: " + (string)k);
                        osTeleportAgent(k, toRegion, toPos, toLookat );
                    }
                }
            }
        }
    }
}
