// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract JwtGroth16Verifier {
    // Scalar field size
    uint256 constant r =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax =
        20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay =
        9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1 =
        4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2 =
        6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1 =
        21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2 =
        10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 =
        9714946962268260166423663705241531742422954741076519273716667832345714852403;
    uint256 constant deltax2 =
        6036915287155654819860389390312939344551242111767083445296955382655968534644;
    uint256 constant deltay1 =
        8098453737911972732819522424143805212797993761755739098203294328833996437386;
    uint256 constant deltay2 =
        15714064580801042504749166463480787557972432199647996651916437139163770942685;

    uint256 constant IC0x =
        19120196643057896296772735953398197626763874599863269113184370231231695794476;
    uint256 constant IC0y =
        17897718438339032856591463528539571604159949460397923629407767636918623233910;

    uint256 constant IC1x =
        15478226453391664983083874016132464062465545625916710547365257503102111701512;
    uint256 constant IC1y =
        20158756509294722884512781700349504441121811768107628677869203071963628300360;

    uint256 constant IC2x =
        1775088051579098731207719937653310305004137372697084718672310113340182159679;
    uint256 constant IC2y =
        11498150609434540586337193225940858130441864278514173054649816397188276868763;

    uint256 constant IC3x =
        5160226694309131737297573904688711656725035262084032892996469432828588874361;
    uint256 constant IC3y =
        14207350092767576530341947438512891152185714850940230482003583117329892007382;

    uint256 constant IC4x =
        3757497172911589544981268536144310902326319747214786240739897195248830490309;
    uint256 constant IC4y =
        10226489715768505782690161715019379707107034890855288911632075402255444139831;

    uint256 constant IC5x =
        2924034274192115588022553585720756239811911016127955619052501101628858603127;
    uint256 constant IC5y =
        3102747376808557313868879033020412723748677807146457492422701533137039714046;

    uint256 constant IC6x =
        9932376604949269734480265335196430720810593415674944427471685140427371598488;
    uint256 constant IC6y =
        4939504174608238351510024634796384662364338608950310304928715200263072545439;

    uint256 constant IC7x =
        21725442581666905298092976317587478498778245338981801310574604580429455495123;
    uint256 constant IC7y =
        5349779035053174059605065406521755656405021878897913954681051017462476035012;

    uint256 constant IC8x =
        16130286961212174234238801167021523100722981958147673892934006199037879307179;
    uint256 constant IC8y =
        2911847352949485267199353394785243782542954716932566723600473143413515152803;

    uint256 constant IC9x =
        13852703381937585666227259080152245750421536068542518450898118687834188547481;
    uint256 constant IC9y =
        2416927597741512813626259585732557268925493570214934175163475410641692628127;

    uint256 constant IC10x =
        20287457798926531341652025023899317597014372485116514500390384786530944547573;
    uint256 constant IC10y =
        10635838046858472272954710321493195746528850538712630612626268793435259484239;

    uint256 constant IC11x =
        7654305975300170400149597423550578479521679002262539995239533328458743140878;
    uint256 constant IC11y =
        15888359715112649987994840473739005657003829708493249279928327262766455827356;

    uint256 constant IC12x =
        13006581493781054313233299149979259044224903118178197971632839236090365514004;
    uint256 constant IC12y =
        3481579263374656943798016330395020014714776493516398372882850671351127531842;

    uint256 constant IC13x =
        6338907822815268422575551849422904357594925635329156751293163777375298761176;
    uint256 constant IC13y =
        20070895980998997629771574579563239745596666271047206732291085152047067001154;

    uint256 constant IC14x =
        3522703628277065258097826982940950797122689986630285344974100397553463461709;
    uint256 constant IC14y =
        4874443991027879161964509549889907027367154576246876676699280843068512443983;

    uint256 constant IC15x =
        13171765681151512949254627218558308635818184223007373169324828667892548776770;
    uint256 constant IC15y =
        4270326545786980498641138448472236398867910695466323547263128707844957142362;

    uint256 constant IC16x =
        17095710710348448670313794659724377962136868914598056469560010832407245134431;
    uint256 constant IC16y =
        16756538031097731686330211719522655898244364950848550690970877149992403809541;

    uint256 constant IC17x =
        9878975915394745295712250526203110207873405495755209711028037455875970588997;
    uint256 constant IC17y =
        10774787637169877605258350801795396606399853619256185492901384037281219888793;

    uint256 constant IC18x =
        11421977469359530543425175692704380965193010385351799606667673694688417737029;
    uint256 constant IC18y =
        18408542399520832658712110065606682368460320489547342594539585065765686719334;

    uint256 constant IC19x =
        20457485057079137468036808603549129323020669662908375086557242452117630347835;
    uint256 constant IC19y =
        4741593424015265331572048148304220508126091578088917719925287303351136356097;

    uint256 constant IC20x =
        15743616752187460172767318299658163149275197436426866258822056943495230190824;
    uint256 constant IC20y =
        15071623197087553066986543208113579383778050347720092739036690493159749058415;

    uint256 constant IC21x =
        6470769963385364529152905640235319880357949911214733957617164424894780340321;
    uint256 constant IC21y =
        5856787240576417346869467658552530811883363067401316197596426703818904299223;

    uint256 constant IC22x =
        6552938195325901789896893432743733712914947473621644039981952183174808751171;
    uint256 constant IC22y =
        18393628663145847571351944753731916134341629807068499943134290202001374256103;

    uint256 constant IC23x =
        17030408051341210523210130321186448963099608804865808214766231026504205386029;
    uint256 constant IC23y =
        20340235697362885037200162258581345517920519591164765208954810718978683206648;

    uint256 constant IC24x =
        3196437451297619106450172496448405417512864871928960118379162949906684593708;
    uint256 constant IC24y =
        8199731962703259685656435139778234312149693652628992379387574838786728066086;

    uint256 constant IC25x =
        4225733741089189090333310242569546523560695645565192096355246238177674403915;
    uint256 constant IC25y =
        11696002781792661603187450614145896808383353764270901689330546258204520870585;

    uint256 constant IC26x =
        7499332060543176412957417847509276456195843153579368842972486975631701983325;
    uint256 constant IC26y =
        16226479184831104955879586502296006953741387726710766654306908717558922160845;

    uint256 constant IC27x =
        12166010116065494140173917445234907419518417465018609017865779905515059359026;
    uint256 constant IC27y =
        6493412130276102384781212889896940725329009626714480453662205797391436499716;

    uint256 constant IC28x =
        6884992605357053261145687464691888241506875696002599522676044876255074517272;
    uint256 constant IC28y =
        7579632261775145657899225990761025134037036652747584225426156410003909377750;

    uint256 constant IC29x =
        19038652169677004281777162280481413450594878487876443995885928183849309702497;
    uint256 constant IC29y =
        18732499908336837497631636657291817514150866751695431347532829596198399614718;

    uint256 constant IC30x =
        17736418557005134723406958103947184478800919470132897502586355706885790653934;
    uint256 constant IC30y =
        5455431393877229712997746535238515377772059832080649533727689046259636999131;

    uint256 constant IC31x =
        18140106760303657253646331064334451316620962299507805063233575918101000468040;
    uint256 constant IC31y =
        5900421789250968537472641625584644702091395926258680943087360654441864972450;

    uint256 constant IC32x =
        3661413691700096638004164439586553274866163178291968582825778328487767858237;
    uint256 constant IC32y =
        9955271061368988417659551687377513449216742783509944056644467577634712001169;

    uint256 constant IC33x =
        6177924070800533902456372958277525048257576544541941586499114102147637476988;
    uint256 constant IC33y =
        10737100291115961694033400631530454973158505710702716496188716775905655100203;

    uint256 constant IC34x =
        19497943738295456121301306337942557495313436957183439787221835472282158298033;
    uint256 constant IC34y =
        3346803329318833889881137440575302710686007060044182806417465056106252522869;

    uint256 constant IC35x =
        16209028733044080583535262702186219959124999860959012688064718536633655427278;
    uint256 constant IC35y =
        7567733394182872818410888333865476952041774251544944618952442060562362157175;

    uint256 constant IC36x =
        5299768431422268917463008536883020503555037002477191747946724842984184982163;
    uint256 constant IC36y =
        1619957955512718184347550856990570395076625696543974463645334752740180851392;

    uint256 constant IC37x =
        1902437495027856959840823369775277536962559251887870648373358473591026116227;
    uint256 constant IC37y =
        12415426099518137317168456578421729762217997882217784571280266433113619881375;

    uint256 constant IC38x =
        7303001951670057302333128834465891962924009730779762816673799978222141710302;
    uint256 constant IC38y =
        20667083733461884645915668725298364501986019220356262927002748525792451460342;

    uint256 constant IC39x =
        8160088042122292920888819596102919572800856468261257899563790832274627735221;
    uint256 constant IC39y =
        123440203811905209942495119668328947713002405955600865809862860944831891970;

    uint256 constant IC40x =
        9831984084895392646229951739401346671497175925077380279548942618095241963945;
    uint256 constant IC40y =
        441203910655747938895436354856612241216427186914849171289890601064967130525;

    uint256 constant IC41x =
        7003495074385279806521947832241390105364700651996653486546685000866410173122;
    uint256 constant IC41y =
        12429609655743386879542587516623391447877678282281341171268040474561562264640;

    uint256 constant IC42x =
        7676159833504141158935305145683297382855502661464472571050011035303053508878;
    uint256 constant IC42y =
        2579450328147452756134865916140150979834293494392345668220180036130435534432;

    uint256 constant IC43x =
        16130661421817129368687560006825275172426504091204007890482357775996443654033;
    uint256 constant IC43y =
        12183997079380635222035040427681445208255181988217268768608771891575701354463;

    uint256 constant IC44x =
        3858338480012235077679475078173075836703103985356734568037598733264668149901;
    uint256 constant IC44y =
        6198492718989626571513574599017981252569152493486434595959975288745827547776;

    uint256 constant IC45x =
        15478911024377148252341852630499626025227960146635923597084531350573976158134;
    uint256 constant IC45y =
        16655323337533125283455878498929489815246883715242690946353887160064893919898;

    uint256 constant IC46x =
        17265783986021676040831976082651951704735837731157300913840260558261000930236;
    uint256 constant IC46y =
        16026984430483554744509014424050832854117570185644504218647293919155297511496;

    uint256 constant IC47x =
        20300857429848552963576080845907082499890314455126468929880749772708048504128;
    uint256 constant IC47y =
        1356323039506466984024641143766181555903889066286165176076406174693608954690;

    uint256 constant IC48x =
        2505909023817791472866124311120324980782699004824231904879847340609915434017;
    uint256 constant IC48y =
        11489413730527245090933646108730019250904122919435653805353451561159179493000;

    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[48] calldata _pubSignals
    ) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x

                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))

                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))

                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))

                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))

                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))

                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))

                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))

                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))

                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))

                g1_mulAccC(
                    _pVk,
                    IC10x,
                    IC10y,
                    calldataload(add(pubSignals, 288))
                )

                g1_mulAccC(
                    _pVk,
                    IC11x,
                    IC11y,
                    calldataload(add(pubSignals, 320))
                )

                g1_mulAccC(
                    _pVk,
                    IC12x,
                    IC12y,
                    calldataload(add(pubSignals, 352))
                )

                g1_mulAccC(
                    _pVk,
                    IC13x,
                    IC13y,
                    calldataload(add(pubSignals, 384))
                )

                g1_mulAccC(
                    _pVk,
                    IC14x,
                    IC14y,
                    calldataload(add(pubSignals, 416))
                )

                g1_mulAccC(
                    _pVk,
                    IC15x,
                    IC15y,
                    calldataload(add(pubSignals, 448))
                )

                g1_mulAccC(
                    _pVk,
                    IC16x,
                    IC16y,
                    calldataload(add(pubSignals, 480))
                )

                g1_mulAccC(
                    _pVk,
                    IC17x,
                    IC17y,
                    calldataload(add(pubSignals, 512))
                )

                g1_mulAccC(
                    _pVk,
                    IC18x,
                    IC18y,
                    calldataload(add(pubSignals, 544))
                )

                g1_mulAccC(
                    _pVk,
                    IC19x,
                    IC19y,
                    calldataload(add(pubSignals, 576))
                )

                g1_mulAccC(
                    _pVk,
                    IC20x,
                    IC20y,
                    calldataload(add(pubSignals, 608))
                )

                g1_mulAccC(
                    _pVk,
                    IC21x,
                    IC21y,
                    calldataload(add(pubSignals, 640))
                )

                g1_mulAccC(
                    _pVk,
                    IC22x,
                    IC22y,
                    calldataload(add(pubSignals, 672))
                )

                g1_mulAccC(
                    _pVk,
                    IC23x,
                    IC23y,
                    calldataload(add(pubSignals, 704))
                )

                g1_mulAccC(
                    _pVk,
                    IC24x,
                    IC24y,
                    calldataload(add(pubSignals, 736))
                )

                g1_mulAccC(
                    _pVk,
                    IC25x,
                    IC25y,
                    calldataload(add(pubSignals, 768))
                )

                g1_mulAccC(
                    _pVk,
                    IC26x,
                    IC26y,
                    calldataload(add(pubSignals, 800))
                )

                g1_mulAccC(
                    _pVk,
                    IC27x,
                    IC27y,
                    calldataload(add(pubSignals, 832))
                )

                g1_mulAccC(
                    _pVk,
                    IC28x,
                    IC28y,
                    calldataload(add(pubSignals, 864))
                )

                g1_mulAccC(
                    _pVk,
                    IC29x,
                    IC29y,
                    calldataload(add(pubSignals, 896))
                )

                g1_mulAccC(
                    _pVk,
                    IC30x,
                    IC30y,
                    calldataload(add(pubSignals, 928))
                )

                g1_mulAccC(
                    _pVk,
                    IC31x,
                    IC31y,
                    calldataload(add(pubSignals, 960))
                )

                g1_mulAccC(
                    _pVk,
                    IC32x,
                    IC32y,
                    calldataload(add(pubSignals, 992))
                )

                g1_mulAccC(
                    _pVk,
                    IC33x,
                    IC33y,
                    calldataload(add(pubSignals, 1024))
                )

                g1_mulAccC(
                    _pVk,
                    IC34x,
                    IC34y,
                    calldataload(add(pubSignals, 1056))
                )

                g1_mulAccC(
                    _pVk,
                    IC35x,
                    IC35y,
                    calldataload(add(pubSignals, 1088))
                )

                g1_mulAccC(
                    _pVk,
                    IC36x,
                    IC36y,
                    calldataload(add(pubSignals, 1120))
                )

                g1_mulAccC(
                    _pVk,
                    IC37x,
                    IC37y,
                    calldataload(add(pubSignals, 1152))
                )

                g1_mulAccC(
                    _pVk,
                    IC38x,
                    IC38y,
                    calldataload(add(pubSignals, 1184))
                )

                g1_mulAccC(
                    _pVk,
                    IC39x,
                    IC39y,
                    calldataload(add(pubSignals, 1216))
                )

                g1_mulAccC(
                    _pVk,
                    IC40x,
                    IC40y,
                    calldataload(add(pubSignals, 1248))
                )

                g1_mulAccC(
                    _pVk,
                    IC41x,
                    IC41y,
                    calldataload(add(pubSignals, 1280))
                )

                g1_mulAccC(
                    _pVk,
                    IC42x,
                    IC42y,
                    calldataload(add(pubSignals, 1312))
                )

                g1_mulAccC(
                    _pVk,
                    IC43x,
                    IC43y,
                    calldataload(add(pubSignals, 1344))
                )

                g1_mulAccC(
                    _pVk,
                    IC44x,
                    IC44y,
                    calldataload(add(pubSignals, 1376))
                )

                g1_mulAccC(
                    _pVk,
                    IC45x,
                    IC45y,
                    calldataload(add(pubSignals, 1408))
                )

                g1_mulAccC(
                    _pVk,
                    IC46x,
                    IC46y,
                    calldataload(add(pubSignals, 1440))
                )

                g1_mulAccC(
                    _pVk,
                    IC47x,
                    IC47y,
                    calldataload(add(pubSignals, 1472))
                )

                g1_mulAccC(
                    _pVk,
                    IC48x,
                    IC48y,
                    calldataload(add(pubSignals, 1504))
                )

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(
                    add(_pPairing, 32),
                    mod(sub(q, calldataload(add(pA, 32))), q)
                )

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))

                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)

                let success := staticcall(
                    sub(gas(), 2000),
                    8,
                    _pPairing,
                    768,
                    _pPairing,
                    0x20
                )

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F

            checkField(calldataload(add(_pubSignals, 0)))

            checkField(calldataload(add(_pubSignals, 32)))

            checkField(calldataload(add(_pubSignals, 64)))

            checkField(calldataload(add(_pubSignals, 96)))

            checkField(calldataload(add(_pubSignals, 128)))

            checkField(calldataload(add(_pubSignals, 160)))

            checkField(calldataload(add(_pubSignals, 192)))

            checkField(calldataload(add(_pubSignals, 224)))

            checkField(calldataload(add(_pubSignals, 256)))

            checkField(calldataload(add(_pubSignals, 288)))

            checkField(calldataload(add(_pubSignals, 320)))

            checkField(calldataload(add(_pubSignals, 352)))

            checkField(calldataload(add(_pubSignals, 384)))

            checkField(calldataload(add(_pubSignals, 416)))

            checkField(calldataload(add(_pubSignals, 448)))

            checkField(calldataload(add(_pubSignals, 480)))

            checkField(calldataload(add(_pubSignals, 512)))

            checkField(calldataload(add(_pubSignals, 544)))

            checkField(calldataload(add(_pubSignals, 576)))

            checkField(calldataload(add(_pubSignals, 608)))

            checkField(calldataload(add(_pubSignals, 640)))

            checkField(calldataload(add(_pubSignals, 672)))

            checkField(calldataload(add(_pubSignals, 704)))

            checkField(calldataload(add(_pubSignals, 736)))

            checkField(calldataload(add(_pubSignals, 768)))

            checkField(calldataload(add(_pubSignals, 800)))

            checkField(calldataload(add(_pubSignals, 832)))

            checkField(calldataload(add(_pubSignals, 864)))

            checkField(calldataload(add(_pubSignals, 896)))

            checkField(calldataload(add(_pubSignals, 928)))

            checkField(calldataload(add(_pubSignals, 960)))

            checkField(calldataload(add(_pubSignals, 992)))

            checkField(calldataload(add(_pubSignals, 1024)))

            checkField(calldataload(add(_pubSignals, 1056)))

            checkField(calldataload(add(_pubSignals, 1088)))

            checkField(calldataload(add(_pubSignals, 1120)))

            checkField(calldataload(add(_pubSignals, 1152)))

            checkField(calldataload(add(_pubSignals, 1184)))

            checkField(calldataload(add(_pubSignals, 1216)))

            checkField(calldataload(add(_pubSignals, 1248)))

            checkField(calldataload(add(_pubSignals, 1280)))

            checkField(calldataload(add(_pubSignals, 1312)))

            checkField(calldataload(add(_pubSignals, 1344)))

            checkField(calldataload(add(_pubSignals, 1376)))

            checkField(calldataload(add(_pubSignals, 1408)))

            checkField(calldataload(add(_pubSignals, 1440)))

            checkField(calldataload(add(_pubSignals, 1472)))

            checkField(calldataload(add(_pubSignals, 1504)))

            checkField(calldataload(add(_pubSignals, 1536)))

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
            return(0, 0x20)
        }
    }
}
