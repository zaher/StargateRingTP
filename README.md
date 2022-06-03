## Opensource Stargate ring teleporter ##

Ground ring to teleport multiple avatars (only 5) to another position in the same region (another region in the future)[TODO]

Idea is based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"

I rebuilt it from scratch the code and the mesh too, with better solution, I used sensor to catch avatars, rez a ring then send a message to that ring to teleport one avatar to the new position.

Works only in one region but i will add cross regions by saving LM in notecard [TODO].


### Setup ###

Easty, rez it , change the description, after rezzing all rings, click `Refresh` in menu, enjoy.
You need refresh button only at then end of setup, or after renaming it in description.

### Buildup ###

You need

* External Ring, as root object that have script
* Internal Ring, name it as "InternalRing" to rotate it linked to the root
* Ring inside inventory of External ring, with name "Ring"

### License ###

https://opensource.org/licenses/MIT

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Open source ###

The source is on github with blender files and textures.

https://github.com/zaher/StargateRingTP

### Syntax ###

I use /*  or  //*  as documentation comment, normal comment is not a documentation, my miniedit highlight it

### Thanks ###

Many THANKs to my Blender teacher "Modee Parlez"
