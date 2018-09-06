# Automated extraction of barriers to diffusive transport in two-dimensional velocity fields

### License

This software is made public for research use only. It may be modified and redistributed
under the terms of the GNU General Public License.

### Algorithm

BarrierTool implements theoretical results developed by the Haller Group at ETH Zurich.
More specifically, the code presented here provides a fully automated identification of 
conservative [1], diffusive [2] transport barriers and their instantaneous (Eulerian) 
counterparts [3] in an objective (observer-independent) fashion.
You may find more details about the underlying algorithm [4] as well as instructions on 
how to navigate through the Graphical User Interface(GUI) in the file "MANUAL.pdf" 
contained in the repository.

### References
[1] G. Haller & F.J. Beron-Vera, Coherent Lagrangian vortices: The black holes of turbulence. 
J. Fluid Mech. 731 (2013) R4.

[2] G. Haller, D. Karrasch & F. Kogelbauer, Material barriers to diffusive and stochastic transport. Proc. Natl. Acad. Sci. U.S.A. (2018).

[3] M. Serra & G. Haller, Objective Eulerian coherent structures. Chaos26 (2016).

[4] M. Serra & G. Haller, Efficient computation of null geodesics with applications to coherent vortex detection. Proc. Royal Soc. A 473 (2017).

### Installation notes

Tested on Matlab R2017a.

Installation notes :

1) After you unzipped the files to mydir, put the Current Directory in Matlab to mydir

2) In the Matlab command prompt, type “null_geo” to open the GUI.

NOTE: This code may be improved and is subject to several changes. Therefore, we suggest to visit this 
page and check if the version you downloaded is up to date.  

Maintained by Stergios Katsanoulis,

katsanos at ethz dot ch

September 5, 2018.
