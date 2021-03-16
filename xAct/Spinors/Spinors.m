xAct`Spinors`$xTensorVersionExpected={"1.1.1",{2014,9,28}};
xAct`Spinors`$Version={"1.0.6",{2014,9,28}}


(* Spinors: spinor calculus in General Relativity *)

(* Copyright (C) 2006-2018 Alfonso Garcia-Parrado Gomez-Lobo and Jose M. Martin-Garcia *)

(* This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License,or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place-Suite 330, Boston, MA 02111-1307, USA. 
*)


(* :Title: Spinors *)

(* :Author: Alfonso Garcia-Parrado Gomez-Lobo and Jose M. Martin-Garcia *)

(* :Summary: spinor calculus in General Relativity *)

(* :Brief Discussion:
   - Spinors extends xAct to perform spinor computations on 4d Lorentzian spacetimes.
   - Defines spin structures, spinors, spin connections and their curvature spinors.
   - Allows conversion from tensors to spinors and viceversa.
   - The documentation explains how to construct the Newman-Penrose and
    Geroch-Held-Penrose formalism.
*)
  
(* :Context: xAct`Spinors` *)

(* :Package Version: 1.0.6 *)

(* :Copyright: Alfonso Garcia-Parrado Gomez-Lobo and Jose M. Martin-Garcia (2006-2018) *)

(* :History: See Spinors.History *)

(* :Keywords: *)

(* :Source: Spinors.nb *)

(* :Warning: *)

(* :Mathematica Version: 6.0 and later *)

(* :Limitations:
	- 4d Lorentzian spacetime only *)


With[{xAct`Spinors`Private`SpinorsSymbols=DeleteCases[Join[Names["xAct`Spinors`*"],Names["xAct`Spinors`Private`*"]],"$Version"|"xAct`Spinors`$Version"|"$xTensorVersionExpected"|"xAct`Spinors`$xTensorVersionExpected"]},
Unprotect/@xAct`Spinors`Private`SpinorsSymbols;
Clear/@xAct`Spinors`Private`SpinorsSymbols;
]


If[Unevaluated[xAct`xCore`Private`$LastPackage]===xAct`xCore`Private`$LastPackage,xAct`xCore`Private`$LastPackage="xAct`Spinors`"];


BeginPackage["xAct`Spinors`",{"xAct`xTensor`","xAct`xPerm`","xAct`xCore`"}]


If[Not@OrderedQ@Map[Last,{xAct`Spinors`$xTensorVersionExpected,xAct`xTensor`$Version}],Throw@Message[General::versions,"xTensor",xAct`xTensor`$Version,xAct`Spinors`$xTensorVersionExpected]]


Print[xAct`xCore`Private`bars]
Print["Package xAct`Spinors`  version ",xAct`Spinors`$Version[[1]],", ",xAct`Spinors`$Version[[2]]];
Print["CopyRight (C) 2006-2018, Alfonso Garcia-Parrado Gomez-Lobo and Jose M. Martin-Garcia, under the General Public License."];


Off[General::shdw]
xAct`Spinors`Disclaimer[]:=Print["These are points 11 and 12 of the General Public License:\n\nBECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM `AS IS\.b4 WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.\n\nIN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES."]
On[General::shdw]


If[xAct`xCore`Private`$LastPackage==="xAct`Spinors`",
Unset[xAct`xCore`Private`$LastPackage];
Print[xAct`xCore`Private`bars];
Print["These packages come with ABSOLUTELY NO WARRANTY; for details type Disclaimer[]. This is free software, and you are welcome to redistribute it under certain conditions. See the General Public License for details."];
Print[xAct`xCore`Private`bars]]


$PrePrint=ScreenDollarIndices;


SetOptions[ContractMetric,AllowUpperDerivatives->True]


SetOptions[MakeRule,MetricOn->All,ContractMetrics->True]


(* Definition of spin structures *)
DefSpinStructure::usage="DefSpinStructure[g, VB, {A,B,C,...}, epsilon, sigma, CDe,  options] defines a spin structure on the manifold in which the metric g[-a, -b] is defined, creating the inner vbundle VB with abstract indices {A,B,C,...}. Currently it only works on 4-dimensional Lorentzian manifolds, and so VB is defined as 2-dimensional and complex. The spin metric is epsilon[-A, -B] and the soldering form is sigma[a, -B, -B\[Dagger]]. The spin covariant derivative CDe,  compatible with sigma and epsilon, is defined on this vbundle extending the Levi-Civita connection of g. We adopt the convention of taking the head of the soldering form as the symbol representing the spin structure.";
UndefSpinStructure::usage="UndefSpinStructure[sp] removes the spin structure associated to the symbol sp and all its dependent objects (servants). The symbol sp can be the soldering form, the vector bundle or the extended covariant derivative.";
$SolderingForms::usage="$SolderingForms is a list containing the set of soldering forms (spin structures) existing in the session.";
SpinorPrefix::usage="SpinorPrefix is an option for DefSpinStructure giving the symbol to be prepended when constructing the spinor equivalent of a tensor or viceversa. By default it is Identity, which is replaced by the soldering form defined with the SpinStructure. SpinorPrefix[sigma] stores that symbol as an upvalue for the soldering form sigma.";
SpinorMark::usage="SpinorMark is an option for DefSpinStructure specifying how to modify the PrintAs string of a tensor when constructing its spinor equivalent. It can be a string (to be prepended to the  PrintAs string) or a function (acting on it). By default it is PrintAs, which is replaced by a delayed call to PrintAs[sigma] for the soldering form sigma. SpinorMark[sigma] stores the value of the option as an upvalue for the soldering form sigma.";
DefSpinor::usage="DefSpinor is a renaming of DefTensor with the option Dagger->Complex, for the sake of clarity.";
UndefSpinor::usage="UndefSpinor is a renaming of UndefTensor, for the sake of clarity.";
Sigma::usage="Sigma[sigma] is automatically transformed into the symbol Sigmasigma, where sigma is a soldering form. The symbol Sigmasigma is the head used to represent the quantity sigma[a,-A,-A\[Dagger]]sigma[b,-B,A\[Dagger]] which often appears in the transformation of spinor expressions into tensor ones.";
PrintDaggerAs::usage="PrintDaggerAs is an optional function for DefSpinor that specifies how the PrintAs string for the complex conjugate spinor should be generated from the PrintAs string for the original spinor.";
AddDagger::usage="Built-in option value for PrintDaggerAs. This option value simply appends the $DaggerCharacter to the string chosen for PrintAs.";
AddBar::usage="Built-in option value for PrintDaggerAs. This option value adds an overbar to the string chosen for PrintAs.";
AddTilde::usage="Built-in option value for PrintDaggerAs. This option value adds a tilde on top of the string chosen for PrintAs.";


(* Info functions *)
TangentBundleOfSolderingForm::usage="TangentBundleOfSolderingForm[sigma] returns the tangent bundle on which the soldering sigma has been defined.";
SpinMetricOfSolderingForm::usage="SpinMetricOfSolderingForm[sigma] returns the antisymmetric spin metric associated to the soldering form sigma.";
VBundleOfSolderingForm::usage="VBundleOfSolderingForm[sigma] returns the inner vbundle (spin bundle) on which the soldering form sigma has been defined.";
SolderingFormOfVBundle::usage="SolderingFormOfVBundle[vbundle] returns the soldering form defined on the vbundle, or Null otherwise.";
SpinCovDsOfSolderingForm::usage="SpinCovDsOfSolderingForm[sigma] returns a list of all covariant derivatives which are compatible with the soldering form sigma.";
SolderingFormOfSpinCovD::usage="SolderingFormOfSpinCovD[SpinCovD] returns the soldering form which is compatible with the covariant derivative SpinCovD";


(* Relations between tensors and spinors *)
DefSpinorOfTensor::usage="DefSpinorOfTensor[sp[inds1],tn[inds2],sigma] defines the spinor counterpart sp[inds1] of the already present tensor tn[inds2] with respect to the spin structure associated to the soldering form sigma. Spinor indices in the sequence inds1 must be sorted according to the pattern index,Dagger[index]. The symmetries of the spinor sp are automatically computed from those of the tensor tn.";
DefTensorOfSpinor::usage="DefTensorOfSpinor[tn[inds1],sp[inds2],sigma] defines the tensor counterpart tn[inds1] of the already present spinor sp[inds2] with respect to the spin structure associated to the soldering form sigma. Spinor indices in the sequence inds2 must be sorted according to the pattern index,Dagger[index]. The symmetries of the tensor tn are automatically computed from those of the spinor sp.";
SpinorOfTensor::usage="SpinorOfTensor[tensor,sigma] gives the spinor counterpart of the tensor named tensor with respect to the spin structure associated to the soldering for sigma.";
TensorOfSpinor::usage="TensorOfSpinor[spinor,sigma] gives the tensor counterpart of the spinor named spinor with respect to the spin structure associated to the soldering for sigma.";


(* Decomposition of a spinor into irreducible parts *)
IrreducibleDecomposition::usage="IrreducibleDecomposition[spinor[inds]] returns the decomposition of the spinor spinor[inds] into totally symmetric irreducible spinors. These are multiplied by apropriate factors of the antisymmetric metric. The irreducible spinors are constructed by appending the TF to the head spinor and using label indices to distinguish the different irreducible spinors intervening in the decomposition";


(* The soldering form *)
PutSolderingForm::usage="PutSolderingForm[expr, inds, sigma] contracts free indices of expr with the soldering form sigma. The free indices are specified by means of the second argument, which can be given in several formats: an index, an IndexList of indices, a conjugated pair Pair[A,A\[Dagger]], a vbundle, a tensor, a covd or an IndicesOf expression with selectors (see xTensor documentation). Both the second and third arguments are sequentially folded over lists. PutSolderingForm[expr, inds] is converted into PutSolderingForm[expr, inds, $SolderingForms]. PutSolderingForm[expr] is converted into PutSolderingForm[expr, IndicesOf[]], adding soldering forms to all possible indices and pairs.";
ContractSolderingForm::usage="ContracSolderingForm[expr, inds] replaces the contracted product of subexpressions in expr with one or several soldering forms by a new expression in which tensor or spinor indices have been inserted appropriately. This process may require the definition of a new tensor or spinor which is handled by the system automatically. The second argument enables us to single out specific soldering forms by selecting the dummy indices in the contracted product, and can be given in several formats: an index, an IndexList of indices, a vbundle, a tensor or an IndicesOf expression with selectors (see xTensor documentation).";
SeparateSolderingForm::usage="SeparateSolderingForm[sigma, basis][expr, inds] separates from expr a number of soldering sigma, creating new dummy indices in the given basis. This may require the definition of a new tensor or spinor, which is carried out automatically. The indices to separate are specified through the inds argument, which can be given in several formats: an index, an IndexList of indices, a vbundle, a tensor, a covd, or an IndicesOf expression with selectors (see xTensor documentation). The default for basis is AIndex, which introduces abstract dummy indices. The sigma argument is folded over lists, and its default is $SolderingForm. SeparateSolderingForm[][expr] is converted into SeparateSolderingForm[][expr, IndicesOf[]], separating all possible soldering forms from expr.";


(* Spinor derivatives and curvature spinors *)
DefSpinCovD::usage="DefSpinCovD[cd[-a],sigma,{post,pre}] defines a spin-compatible covariant derivative cd with respect to the spin structure associated to the soldering form sigma. This covariant derivative will be represented in StandardForm using the character pre in PreFix notation and the character post in PostFix notation. DefSpinCovD supports similar options as the xTensor command DefSpinCovD.";
UndefSpinCovD::usage="UndefSpinCov[scd] undefines the spin-compatible covariant derivative scd.";
SpinCovDQ::usage="SpinCovDQ[cd] returns True if the symbol cd has been declared as a spin covariant derivative using DefSpinCovD, and False otherwise.";
Chi::usage="Chi is a reserved symbol in Spinors denoting the first curvature spinor.";
Phi::usage="Phi is a reserved symbol in Spinors denoting the second curvature spinor.";
Psi::usage="Psi is a reserved symbol in Spinors denoting the Weyl spinor.";
Lambda::usage="Lambda is a reserved symbol in Spinors denoting the Lambda scalar.";
Omega::usage="Omega is a reserved symbol in Spinors denoting the torsion spinor";
$ChiSign::usage="$ChiSign is a global variable which sets the sign convention adopted to define the first curvature spinor. Its default value is +1.";
$PhiSign::usage="$PhiSign is a global variable which sets the sign convention adopted to define the second curvature spinor. Its default value is +1.";
$PsiSign::usage="$PsiSign is a global variable which sets the sign convention adopted to define the Weyl spinor. Its default value is +1.";
$LambdaSign::usage="$LambdaSign is a global variable which sets the sign convention adopted to define the Lambda scalar. Its default value is +1.";
$OmegaSign::usage="$OmegaSign is a global variable which sets the sign convention adopted to define the torsion spinor. Its default value is +1.";
Decomposition::usage="Decomposition[expr, object, covd] decomposes curvature tensors of covd in expr according to predefined rules. Possible objects are Riemann, Ricci, TFRicci, Weyl, RicciScalar, FRiemann or Chi.";
BoxToCovD::usage="BoxToCovD[expr,boxcd] expands all instances of boxcd into symmetrized second covariant derivatives, according to the definition of the box operator.";
BoxToCurvature::usage="BoxToCurvature[expr,boxcd] expands all instances of boxcd into expressions which are linear in the curvature spinors of the spin covariant derivative cd.";
SortSpinCovDs::usage="SortSpinCovDs[expr,spincovd] performs a function similar to SortCovDs for 2-index spin covariant derivatives. The basic identity used to re-order the spin covariant derivatives is their commutator in terms of the box operator";


Begin["`Private`"]


$ContextPath


CheckMetric[metric_,tbundle_]:=
Which[
!MetricQ[metric],Throw@Message[DefSpinStructure::unknown,"metric",metric],xAct`xTensor`Private`FrozenMetricQ[metric],Throw@Message[DefSpinStructure::error,"A frozen metric cannot be used."],
TangentBundleOfManifold@BaseOfVBundle@tbundle=!=tbundle,
Throw@Message[DefSpinStructure::error,"The metric must be defined on a tangent bundle."],
DimOfVBundle[tbundle]=!=4,
Throw@Message[DefSpinStructure::notyet,"non 4d manifolds"],
SignDetOfMetric[metric]=!=-1,
Throw@Message[DefSpinStructure::invalid,metric,"Lorentzian metric"],
SignatureOfMetric[metric]=!={1,3,0},
Throw@Message[DefSpinStructure::invalid,metric,"metric of signature +,-,-,-."]
];


SetAttributes[{isetdelayed,itagset,itagsetdelayed},HoldAll];
isetdelayed=SetDelayed;
itagset=TagSet;
itagsetdelayed=TagSetDelayed;


$SolderingForms={};


Sigma[sigma_Symbol]:=GiveSymbol[Sigma,sigma];
GiveOutputString[Sigma,sigma_Symbol]:=StringJoin["\[CapitalSigma]",PrintAs[sigma]];
SetNumberOfArguments[Sigma,1];
Protect[Sigma];


(* Options for formatting *)
Options[DefSpinStructure]:={
SpinorPrefix->Identity,
SpinorMark->PrintAs,
DefInfo->{"spin structure",""}
};
(* Backwards compatibility *)
DefSpinStructure[metric_,vbundle_,vbinds_,eps_,sigma_,cd_,cdsymbols:{_String,_String},options:OptionsPattern[]]:=DefSpinStructure[metric,vbundle,vbinds,eps,sigma,cd,SymbolOfCovD->cdsymbols,options];
(* Main *)
DefSpinStructure[metric_Symbol,vbundle_Symbol,vbinds_List,eps_Symbol,sigma_Symbol,cd_Symbol,options:OptionsPattern[]]:=Catch@With[{tbundle=VBundleOfMetric[metric]},
CheckMetric[metric,tbundle];
With[
{base=BaseOfVBundle[tbundle],
covd=CovDOfMetric[metric]},

(* 1. Create 2d complex inner vbundle *)
DefVBundle[vbundle,base,2,vbinds,Dagger->Complex,FilterRules[{options},Options[DefVBundle]]];

(* 2. Relations in the spin structure *)
VBundleOfSolderingForm[sigma]^=vbundle;
SolderingFormOfVBundle[vbundle]^=sigma;
TangentBundleOfSolderingForm[sigma]^=tbundle;
SpinMetricOfSolderingForm[sigma]^=eps;
SpinCovDsOfSolderingForm[sigma]^={};(*{cd};*)
SolderingFormOfSpinCovD[cd]^=sigma;

(* 3. Construct indices and feed them with With *)
Module[{Ai,Adi,Bi,Bdi,Ci,Cdi,Di,Ddi,ai,bi,ci,di,ei,fi},
{Ai,Bi,Ci,Di}=GetIndicesOfVBundle[vbundle,4,{}];
{Adi,Bdi,Cdi,Ddi}=DaggerIndex/@{Ai,Bi,Ci,Di};
{ai,bi,ci,di,ei,fi}=GetIndicesOfVBundle[tbundle,6,{}];
With[{A=Ai,Ad=Adi,B=Bi,Bd=Bdi,C=Ci,Cd=Cdi,D=Di,Dd=Ddi,a=ai,b=bi,c=ci,d=di,e=ei,f=fi,vbundledag=Dagger[vbundle],epsdag=MakeDaggerSymbol[eps]},

(* 4. Define the soldering form *)
DefTensor[sigma[a,-C,-Dd],base,Dagger->Hermitian,ProtectNewSymbol->False,Master->vbundle,DefInfo->{"soldering form",""},FilterRules[{options},Options[DefTensor]]];
AppendTo[$SolderingForms,sigma];

(* 5. Define eps and its conjugate *)
DefTensor[eps[-A,-B],base,Antisymmetric[{1,2}],Dagger->Complex,ProtectNewSymbol->False,Master->sigma,DefInfo->{"spin metric",""},FilterRules[{options},Options[DefTensor]]];
(* Metric properties *)
MetricQ[eps]^=True;
MetricQ[epsdag]^=True;
xUpAppendTo[MetricsOfVBundle[vbundle],eps];
xUpAppendTo[MetricsOfVBundle[vbundledag],epsdag];
VBundleOfMetric[eps]^=vbundle;
VBundleOfMetric[epsdag]^=vbundledag;
$Metrics=Join[$Metrics,{eps,epsdag}];
InducedFrom[eps]^=Null;
InducedFrom[epsdag]^=Null;
(* Conversion into delta for mixed abstract indices *)
isetdelayed[eps[A_Symbol,-B_Symbol],delta[A,-B]];
isetdelayed[eps[-A_Symbol,B_Symbol],delta[-A,B]];
isetdelayed[epsdag[A_Symbol,-B_Symbol],delta[A,-B]];
isetdelayed[epsdag[-A_Symbol,B_Symbol],delta[-A,B]];

(* 6. Spinor construction *)
Module[{sigmaprefix,sigmamark},
{sigmaprefix,sigmamark}=OptionValue[{DefSpinStructure,DefCovD},{options},{SpinorPrefix,SpinorMark}];
SpinorPrefix[sigma]^=If[sigmaprefix===Identity,sigma,sigmaprefix];
SpinorMark[sigma]^=If[sigmamark===PrintAs,PrintAs[sigma],sigmamark];
];

(* 7. Products of two sigma *)
With[{vQ=xAct`xTensor`Private`VBundleIndexPMQ[vbundle],vdQ=xAct`xTensor`Private`VBundleIndexPMQ[vbundledag]},
itagset[sigma,sigma[a_,A_,Dd_]sigma[-a_,C_,Cd_],eps[A,C]epsdag[Dd,Cd]];
AutomaticRules[sigma,MakeRule[{sigma[a,-B,-Dd]sigma[b,B,Dd],metric[a,b]},MetricOn->All,ContractMetrics->False,TestIndices->False],Verbose->False]
];
With[{Sigmaname=GiveSymbol[Sigma,sigma],Tetraname=Tetra[metric]},
DefTensor[Sigmaname[a,b,-A,-B],base,StrongGenSet[{1},GenSet[-xAct`xPerm`Cycles[{1,2},{3,4}]]],PrintAs:>GiveOutputString[Sigma,sigma],Dagger->Complex,Master->sigma,FilterRules[{options},Options[DefTensor]]];
Sigmaname[a_,b_,C_,-C_]:=-metric[a,b];
Sigmaname[a_,b_,-C_,C_]:=metric[a,b];
Sigmaname[a_,-a_,C_,D_]:=-2eps[C,D];
Sigmaname[-a_,a_,C_,D_]:=-2eps[C,D];
With[{Sigmanamedag=Dagger[Sigmaname],Tetranamedag=Dagger[Tetraname]},
Sigmanamedag[a_,b_,Cd_,-Cd_]:=-metric[a,b];
Sigmanamedag[a_,b_,-Cd_,Cd_]:=metric[a,b];
Sigmanamedag[a_,-a_,Cd_,Dd_]:=-2epsdag[Cd,Dd];
Sigmanamedag[-a_,a_,Cd_,Dd_]:=-2epsdag[Cd,Dd];
AutomaticRules[Sigmaname,MakeRule[{Sigmaname[a,b,A,B]Sigmaname[c,d,C,-B],-Tetraname[b,d,-e,a]Sigmaname[e,c,A,C]},MetricOn->{a,b,c,d,A,C},ContractMetrics->True],Verbose->False];
AutomaticRules[Sigmanamedag,MakeRule[{Sigmanamedag[a,b,Ad,Dd]Sigmanamedag[c,d,Cd,-Dd],-Tetranamedag[b,d,-e,a]Sigmanamedag[e,c,Ad,Cd]},MetricOn->{a,b,c,d,Ad,Cd},ContractMetrics->True],Verbose->False];

itagsetdelayed[Sigmaname,Tetraname[a_,b_,c_,d_]Sigmaname[e_,f_,C_,D_],Condition[metric[a,b]eps[C,D],PairQ[c,e]&&PairQ[d,f]||PairQ[c,f]&&PairQ[d,e]]];
itagsetdelayed[Sigmaname,Tetraname[c_,d_,a_,b_]Sigmaname[e_,f_,C_,D_],Condition[metric[a,b]eps[C,D],PairQ[c,e]&&PairQ[d,f]||PairQ[c,f]&&PairQ[d,e]]];

itagsetdelayed[Sigmanamedag,Tetranamedag[a_,b_,c_,d_]Sigmanamedag[e_,f_,Cd_,Dd_],Condition[metric[a,b]epsdag[Cd,Dd],PairQ[c,e]&&PairQ[d,f]||PairQ[c,f]&&PairQ[d,e]]];
itagsetdelayed[Sigmanamedag,Tetranamedag[c_,d_,a_,b_]Sigmanamedag[e_,f_,Cd_,Dd_],Condition[metric[a,b]epsdag[Cd,Dd],PairQ[c,e]&&PairQ[d,f]||PairQ[c,f]&&PairQ[d,e]]];
];
];

(* 8. Define the spinor equivalent of the metric tensor and the volume element *)
With[{MetricName=AddSpinorPrefix[metric,SpinorPrefix[sigma]],EpsilonSpin=AddSpinorPrefix[epsilon@metric,SpinorPrefix[sigma]]},
DefSpinorOfTensor[MetricName[A,Cd,B,Dd],metric[-a,-b],sigma,FilterRules[{options},Options[DefTensor]]];
itagset[MetricName,MetricName[A_,Cd_,B_,Dd_],eps[A,B]epsdag[Cd,Dd]];
DefSpinorOfTensor[EpsilonSpin[A,Ad,B,Bd,C,Cd,D,Dd],epsilon[metric][-a,-b,-c,-d],sigma,options];
itagsetdelayed[EpsilonSpin,EpsilonSpin[A_,Ad_,B_,Bd_,C_,Cd_,D_,Dd_],epsilonOrientation[metric,AIndex] I (-eps[A,D]eps[B,C]epsdag[Ad,Cd]epsdag[Bd,Dd]+eps[A,C]eps[B,D]epsdag[Ad,Dd]epsdag[Bd,Cd])];
];

(* 9. Define the covariant derivative (and the curvature spinors) *)
DefSpinCovD[cd[-a],sigma,Torsion->TorsionQ@covd,ExtendedFrom->covd,Master->sigma,ProtectNewSymbol->False,FilterRules[{options},Options[DefSpinCovD]]];
(* Compatibility with metric, for all index configurations *)
isetdelayed[cd[a__][eps[A_,B_]],0];
isetdelayed[cd[a__][epsdag[A_,B_]],0];
CovDOfMetric[eps]^=cd;
CovDOfMetric[epsdag]^=cd;

]
]
]
];
SetNumberOfArguments[DefSpinStructure,{7,Infinity}];
Protect[DefSpinStructure];


UndefSpinStructure[vbundle_?VBundleQ]:=UndefSpinStructure[SolderingFormOfVBundle[vbundle]];
UndefSpinStructure[covd_?CovDQ]:=UndefSpinStructure[SolderingFormOfSpinCovD[covd]];
UndefSpinStructure[sigma_?xTensorQ]:=With[{newlist=DeleteCases[$SolderingForms,sigma]},
UndefVBundle[VBundleOfSolderingForm[sigma]];
$SolderingForms=newlist;]/;MemberQ[$SolderingForms,sigma];
UndefSpinStructure[x_]:=Throw@Message[UndefSpinStructure::unknown,"spin structure", x];
SetNumberOfArguments[UndefSpinStructure,1];
Protect[UndefSpinStructure];


AddBar[T_?xTensorQ]:=StringJoin["\!\(","\*OverscriptBox[\(",PrintAs@Evaluate@Dagger[T],"\),\(_\)]","\)"];
AddTilde[T_?xTensorQ]:=StringJoin["\!\(","\*OverscriptBox[\(",PrintAs@Evaluate@Dagger@T,"\),\(~\)]","\)"];
AddDagger[T_?xTensorQ]:=StringJoin[PrintAs@Evaluate@Dagger@T,$DaggerCharacter];


Options[DefSpinor]={PrintDaggerAs->AddDagger};
DefSpinor[spinor_[inds___],deps_,options:OptionsPattern[{DefSpinor,DefTensor}]]:=(DefTensor[spinor[inds],deps,FilterRules[{options},Options[DefTensor]],Dagger->Complex,DefInfo->{"spinor",""}];
If[Dagger@spinor=!=spinor,
xAct`xTensor`Private`SetPrintAs[Dagger@spinor,xAct`xTensor`Private`PrintAsString[Dagger@spinor,OptionValue[PrintDaggerAs]]]
];);

DefSpinor[spinor_[inds___],deps_,sym_,options:OptionsPattern[{DefSpinor,DefTensor}]]:=(DefTensor[spinor[inds],deps,sym,FilterRules[{options},Options[DefTensor]],Dagger->Complex,DefInfo->{"spinor",""}];
If[Dagger@spinor=!=spinor,
xAct`xTensor`Private`SetPrintAs[Dagger@spinor,xAct`xTensor`Private`PrintAsString[Dagger@spinor,OptionValue[PrintDaggerAs]]]
];);
UndefSpinor=UndefTensor;
SetNumberOfArguments[DefSpinor,{2,Infinity}];
Protect[DefSpinor,UndefSpinor];


AddSpinorPrefix[object_Symbol,prefix_Symbol]:=ASP[UnlinkSymbol[object],prefix];
ASP[{prefix_,other__},prefix_]:=LinkSymbols[{other}];
ASP[{other__},prefix_]:=LinkSymbols[{prefix,other}];


SpinorOfTensor::name="Spinor of `1` not defined. Prepending `2`.";
TensorOfSpinor::name="Tensor of `1` not defined. Prepending `2`.";
SpinorOfTensor[tensor_,sigma_]:=With[{prefix=SpinorPrefix[sigma]},Message[SpinorOfTensor::name,tensor,prefix];AddSpinorPrefix[tensor,prefix]];
TensorOfSpinor[spinor_,sigma_]:=With[{prefix=SpinorPrefix[sigma]},Message[TensorOfSpinor::name,spinor,prefix];AddSpinorPrefix[spinor,prefix]];
(* Default choice of spinor prefix *)
SpinorPrefix[sigma_]:=sigma;
SetNumberOfArguments[SpinorPrefix,1];
SetNumberOfArguments[SpinorOfTensor,2];
SetNumberOfArguments[TensorOfSpinor,2];
Protect[SpinorPrefix,SpinorOfTensor,TensorOfSpinor];


AddSpinorMark[character_String,mark_String]:=StringJoin[mark,character];
AddSpinorMark[character_String,function_]:=function[character];


(* Same index: shift slots *)
indRules[f_,{vbundle_,nv_,IndexList[A_,spinds___]},{tbundle_,nt_,IndexList[A_,inds___]},rules_List]:=indRules[f,{vbundle,nv+1,IndexList[spinds]},{tbundle,nt+1,IndexList[inds]},Append[rules,nt->nv]];
(* tbundle index corresponds to a pair of vbundle/vbundledag indices *)
indRules[f_,{vbundle_,nv_,IndexList[A_,Bd_,spinds___]},{tbundle_,nt_,IndexList[a_,inds___]},rules_List]:=
indRules[f,{vbundle,nv+2,IndexList[spinds]},{tbundle,nt+1,IndexList[inds]},Append[rules,nt->{nv,nv+1}]]/;AIndexQ[A,vbundle]&&AIndexQ[Bd,Dagger[vbundle]]&&AIndexQ[a,tbundle];
(* Exit point *)
indRules[f_,{_,_,IndexList[]},{_,_,IndexList[]},rules_List]:=rules;
(* Other case: error *)
General::incomp="Indices `1` and `2` are incompatible.";
indRules[DefSpinorOfTensor,{_,_,spinds_},{_,_,inds_},_]:=Throw@Message[DefSpinorOfTensor::incomp,spinds,inds];
indRules[DefTensorOfSpinor,{_,_,spinds_},{_,_,inds_},_]:=Throw@Message[DefTensorOfSpinor::incomp,inds,spinds];


(* This assumes a GenSet in cyclic form *)
SpinorSymmetry[tensor_[inds___],rules_List]:=SymmetryGroupOfTensor[tensor[inds]]/.StrongGenSet[base_,genset_]:>StrongGenSet[first/@(base/.rules),genset/.perm_Cycles:>spinorCycles[rules]/@perm];
first[i_Integer]:=i;
first[list_List]:=First[list];
spinorCycles[rules_List][cycle_List]:=spinorCyclesTranspose[cycle/.rules];
spinorCyclesTranspose[cycle:{__Integer}]:=cycle;
spinorCyclesTranspose[cycle:{{_,_}..}]:=Sequence@@Transpose[cycle];
spinorCyclesTranspose[cycle_]:=Throw@Message[DefSpinorOfTensor::error,"Symmetry of tensor incompatible with indices."];


(* This assumes a GenSet in cyclic form *)
SymmetryOfTensor[spinor_[spinds___],rules_List]:=With[{firstrules=Map[first,rules,{2}]},
SymmetryGroupOfTensor[spinor[spinds]]/.StrongGenSet[base_,genset_]:>StrongGenSet[Cases[base,Alternatives@@(First/@firstrules)]/.firstrules,genset/.perm_Cycles:>tensorCycles[firstrules]/@perm]
];
tensorCycles[firstrules_List][cycle_List]:=Which[
Complement[cycle,First/@firstrules]==={},cycle/.firstrules,
Intersection[cycle,First/@firstrules]==={},{},
True,Throw@Message[DefTensorOfSpinor::error,"Symmetry of spinor cannot be reduced to tensor."]];


DefSpinorOfTensor[spinor_Symbol[spinds___],tensor_Symbol[inds___],sigma_Symbol,options:OptionsPattern[]]:=Catch@Module[{vbundle,tbundle,rules,sym},

(* Check tensor *)
If[!xTensorQ[tensor],Throw@Message[DefSpinorOfTensor::unknown,"tensor",tensor]];

(* VBundles *)
vbundle=VBundleOfSolderingForm[sigma];
tbundle=TangentBundleOfSolderingForm[sigma];

(* Check index compatibility and construct rules *)
rules=indRules[DefSpinorOfTensor,{vbundle,1,IndexList[spinds]},{tbundle,1,IndexList[inds]},{}];
sym=SpinorSymmetry[tensor[inds],rules];

(* Define spinor. Do not give master *)
DefTensor[spinor[spinds],DependenciesOfTensor[tensor],sym,Dagger:>If[DaggerQ[tensor],Complex,Hermitian],Master->Null,FilterRules[{options},Options[DefTensor]],
PrintAs:>AddSpinorMark[PrintAs[tensor],SpinorMark[sigma]],DefInfo->{"spinor","Equivalent of tensor "<>ToString[tensor],"Equivalent of tensor "<>ToString[Dagger[tensor]]}];

(* Register *)
RegisterSpinorOfTensor[spinor,tensor,sigma];
SetVisitorHost[spinor,tensor,sigma];
If[DaggerQ@tensor,
RegisterSpinorOfTensor[Dagger[spinor],Dagger[tensor],sigma];
(* SetVisitorHost[Dagger[spinor],Dagger[tensor],sigma]*)];

];
SetNumberOfArguments[DefSpinorOfTensor,{3,Infinity}];
Protect[DefSpinorOfTensor];


RegisterSpinorOfTensor[spinor_,tensor_,sigma_]:=(
xTagSet[{tensor,SpinorOfTensor[tensor,sigma]},spinor];
xTagSet[{spinor,TensorOfSpinor[spinor,sigma]},tensor];
);
SetVisitorHost[visitor_,host_,sigma_]:=(
xUpAppendTo[HostsOf[visitor],sigma];
xUpAppendTo[HostsOf[visitor],host];
xUpAppendTo[VisitorsOf[sigma],visitor];
xUpAppendTo[VisitorsOf[host],visitor];
);


DefTensorOfSpinor[tensor_Symbol[inds___],spinor_Symbol[spinds___],sigma_Symbol,options:OptionsPattern[]]:=Catch@Module[{vbundle,tbundle,rules,sym},

(* Check spinor *)
If[!xTensorQ[spinor],Throw@Message[DefTensorOfSpinor::unknown,"spinor",spinor]];

(* VBundles *)
vbundle=VBundleOfSolderingForm[sigma];
tbundle=TangentBundleOfSolderingForm[sigma];

(* Check index compatibility and construct rules *)
rules=Reverse/@indRules[DefTensorOfSpinor,{vbundle,1,IndexList[spinds]},{tbundle,1,IndexList[inds]},{}];
sym=SymmetryOfTensor[spinor[spinds],rules];

(* Define tensor. Do not give master *)
DefTensor[tensor[inds],DependenciesOfTensor[spinor],sym,Dagger:>If[HermitianQ[spinor],Real,Complex],Master->Null,FilterRules[{options},Options[DefTensor]],
PrintAs:>AddSpinorMark[PrintAs[spinor],SpinorMark[sigma]],DefInfo->{"tensor","Equivalent of spinor "<>ToString[spinor],"Equivalent of spinor "<>ToString[Dagger[spinor]]}];

(* Register *)
RegisterSpinorOfTensor[spinor,tensor,sigma];
SetVisitorHost[tensor,spinor,sigma];
If[DaggerQ[tensor],
RegisterSpinorOfTensor[Dagger[spinor],Dagger[tensor],sigma];
(* SetVisitorHost[Dagger[spinor],Dagger[tensor],sigma]*);
];

];
SetNumberOfArguments[DefTensorOfSpinor,{3,Infinity}];
Protect[DefTensorOfSpinor];


(* Return an IndexList of Pair pairs *)
FindPairs[expr_,vbs_List]:=IndexList@@Apply[Join,
xAct`xTensor`Private`TransposeDaggerPairs[#,vbs,False]&/@Join[
FindAllOfType[expr,Tensor],Cases[FindAllOfType[expr,CovD],_Symbol?SpinCovDQ[a_,b_][_]->IndexList[a,b]]
]
];
(* Separate pairs in the given indices list *)
FindPairs[expr_,vbs_List,indices_IndexList]:=With[{pairs=FindPairs[expr,vbs]},
Flatten[{List@@Complement[indices,Flatten[Apply[IndexList,pairs,1],1]],Cases[pairs,pair_/;Intersection[IndexList@@pair,indices]=!=IndexList[]]},1]
];


(* Shortcuts for the third argument *)
PutSolderingForm[expr_]:=PutSolderingForm[expr,IndicesOf[]];
PutSolderingForm[expr_,inds_]:=PutSolderingForm[expr,inds,$SolderingForms];
PutSolderingForm[expr_,inds_,list_List]:=Fold[PutSolderingForm[#1,inds,#2]&,expr,list];
(* Second argument *)
PutSolderingForm[expr_,ind_?GIndexQ,sigma_Symbol]:=PutSolderingForm[expr,IndexList[ind],sigma];
PutSolderingForm[expr_,list_List,sigma_Symbol]:=Fold[PutSolderingForm[#1,#2,sigma]&,expr,list];
PutSolderingForm[expr_,master:(_Symbol?VBundleQ|_Symbol?xTensorQ|_Symbol?CovDQ),sigma_Symbol]:=PutSolderingForm[expr,IndicesOf[Free,master],sigma];
PutSolderingForm[expr_,f_IndicesOf,sigma_Symbol]:=PutSolderingForm[expr,DeleteDuplicates[Prepend[f,Free]][expr],sigma];
(* Actual working function. Two entry points *)
PutSolderingForm[expr_,pair_Pair,sigma_Symbol]:=PutSolderingForm1[VBundleOfSolderingForm[sigma],sigma][expr,pair];
PutSolderingForm[expr_,inds_IndexList,sigma_Symbol]:=With[{vbundle=VBundleOfSolderingForm[sigma]},Fold[PutSolderingForm1[vbundle,sigma],expr,FindPairs[expr,{vbundle,Dagger[vbundle]},inds]]
];
(* Other *)
SetNumberOfArguments[PutSolderingForm,{1,3}];
Protect[PutSolderingForm];


PutSolderingForm1[vbundle_,sigma_][expr_,Pair[index1_,index2_]]:=
With[{indices=FindIndices[expr]},
(* Some Checks *)
If[Or[
VBundleOfIndex[index1]=!=vbundle,
VBundleOfIndex[index2]=!=Dagger[vbundle],
FreeQ[indices,index1],
FreeQ[indices,index2]
],
(* Problem: do nothing *)
expr,
(* Do Put *)
Module[{A1=DummyAs[index1],A2=DummyAs[index2],a=If[UpIndexQ[index1],UpIndex,DownIndex]@First@GetIndicesOfVBundle[TangentBundleOfManifold@BaseOfVBundle[vbundle],1,UpIndex/@FindIndices@expr]},
ReplaceIndex[expr,{index1->A1,index2->A2}]sigma[a,-A1,-A2]
]
]
];


PutSolderingForm1[vbundle_,sigma_][0,AnyIndices]:=0;
PutSolderingForm1[vbundle_,sigma_][expr_,index_]:=
With[{indices=FindIndices[expr]},
(* Some Checks *)
If[Or[
VBundleOfIndex[index]=!=TangentBundleOfManifold@BaseOfVBundle[vbundle],
FreeQ[indices,index]
],
(* Problem: do nothing *)
expr,
(* Do Put *)
Module[{a,A,inds=UpIndex/@indices},
a=DummyAs[index];
inds=Union[inds,DaggerIndex/@inds];
A=If[UpIndexQ[index],UpIndex,DownIndex]@First@GetIndicesOfVBundle[vbundle,1,inds];
ReplaceIndex[expr,index->a]sigma[-a,A,DaggerIndex[A]]
]
]
];


(* Single option *)
Options[ContractSolderingForm]:={OverDerivatives->True};
(* Shortcuts *)
ContractSolderingForm[expr_,options:OptionsPattern[]]:=ContractSolderingForm[expr,IndicesOf[],options];
ContractSolderingForm[expr_,tensor_Symbol?xTensorQ,options:OptionsPattern[]]:=ContractSolderingForm[expr,IndicesOf[tensor],options];
ContractSolderingForm[expr_,vbundle_Symbol?VBundleQ,options:OptionsPattern[]]:=ContractSolderingForm[expr,IndicesOf[vbundle],options];
ContractSolderingForm[expr_,index_?GIndexQ,options:OptionsPattern[]]:=ContractSolderingForm[expr,IndexList[index],options];
ContractSolderingForm[expr_,f_IndicesOf,options:OptionsPattern[]]:=ContractSolderingForm[expr,f[expr],options];
(* Main definition *)
ContractSolderingForm[expr_,list_IndexList,options:OptionsPattern[]]:=Fold[CSF1[OptionValue[OverDerivatives],list],Expand[expr],$SolderingForms];
(* Other *)
SetNumberOfArguments[ContractSolderingForm,{1,Infinity}];
Protect[ContractSolderingForm];


(* Plus: thread *)
CSF1[TF_,inds_IndexList][expr_Plus,sigma_]:=CSF1[TF,inds][#,sigma]&/@expr;
CSF1[TF_,inds_IndexList][0,sigma_]:=0;
CSF1[TF_,inds_IndexList][expr_,sigma_]:=RemoveTMP@Fold[CSF2[TF,sigma],expr,inds];
RemoveTMP[expr_]:=expr/.new:(SpinorTMP|TensorTMP)[__][___]:>ArrangeSpinTMP[new];


CSF2[TF_,sigma_][expr_,i_]:=CSF2[TF,sigma][expr,i,ChangeIndex[i],DaggerIndex[i]===i];


(* Contraction with tensors and derivatives *)
CSF2[False,sigma_][expr_,i_?ABIndexQ,ic_,True]:=Expand[expr/.{
sigma[i,a_,b_]tensor_?xTensorQ[i1___,ic,i2___]:>If[HasDaggerCharacterQ[tensor],
SpinorTMP[tensor,sigma][i1,b,a,i2],SpinorTMP[tensor,sigma][i1,a,b,i2]],sigma[ic,a_,b_]tensor_?xTensorQ[i1___,i,i2___]:>If[HasDaggerCharacterQ[tensor],SpinorTMP[tensor,sigma][i1,b,a,i2],SpinorTMP[tensor,sigma][i1,a,b,i2]],
sigma[i,a_,b_]covd_Symbol?SpinCovDQ[ic][expr1_]:>covd[a,b][expr1],
sigma[ic,a_,b_]covd_Symbol?SpinCovDQ[i][expr1_]:>covd[a,b][expr1]}
];
(* Recursion through covariant derivatives *)
CSF2[True,sigma_][expr_,i_?AIndexQ,ic_,True]:=Expand[CSF2[False,sigma][expr,i,ic,True]/.rest_. sigma[i,a_,b_]covd_Symbol?CovDQ[inds__][expr1_]:>rest covd[inds][CSF2[True,sigma][sigma[i,a,b]expr1,i,ic,True]]/;IsIndexOf[expr1,ic]&&SolderingFormOfSpinCovD[covd]===sigma];
(* For other types of indices, do nothing *)
CSF2[_,_][expr_,_,_,True]:=expr;


SST[sigma_,a_][spinor_,{i1___},{ic_,jc_},{i2___}]:=TensorTMP[spinor,sigma,a:>Sequence[ic,jc]][i1,a,i2];


(* Contraction with tensors and 2-index derivatives *)
CSF2[False,sigma_][expr_,i_?EIndexQ,ic_,False]:=Expand[expr/.{
sigma[a_,j_,i]sigma[b_,k_,ic?UpIndexQ]:>Sigma[sigma][a,b,j,k],
sigma[a_,i,j_]sigma[b_,ic?UpIndexQ,k_]:>Dagger[Sigma[sigma]][a,b,j,k],
(sigma[a_,j_,i]|sigma[a_,i,j_])spinor_?xTensorQ[i1___,ic,jc_,i2___]:>SST[sigma,a][spinor,{i1},{ic,jc},{i2}]/;PairQ[j,jc],
(sigma[a_,jc_,ic]|sigma[a_,ic,jc_])spinor_?xTensorQ[i1___,i,j_,i2___]:>SST[sigma,a][spinor,{i1},{i,j},{i2}]/;PairQ[j,jc],
(sigma[a_,i,j_]|sigma[a_,j_,i])spinor_?xTensorQ[i1___,jc_,ic,i2___]:>SST[sigma,a][spinor,{i1},{jc,ic},{i2}]/;PairQ[j,jc],
(sigma[a_,jc_,ic]|sigma[a_,ic,jc_])spinor_?xTensorQ[i1___,j_,i,i2___]:>SST[sigma,a][spinor,{i1},{j,i},{i2}]/;PairQ[j,jc],
sigma[a_,i,j_]covd_?SpinCovDQ[ic,jc_][expr1_]:>CovDSpinSign[ic,jc]covd[a][expr1]/;PairQ[j,jc],
sigma[a_,ic,jc_]covd_?SpinCovDQ[i,j_][expr1_]:>CovDSpinSign[i,j]covd[a][expr1]/;PairQ[j,jc],
sigma[a_,j_,i]covd_?SpinCovDQ[jc_,ic][expr1_]:>CovDSpinSign[jc,ic]covd[a][expr1]/;PairQ[j,jc],
sigma[a_,jc_,ic]covd_?SpinCovDQ[j_,i][expr1_]:>CovDSpinSign[j,i]covd[a][expr1]/;PairQ[j,jc]}
];
(* Recursion through covariant derivatives *)
CSF2[True,sigma_][expr_,i_?AIndexQ,ic_,False]:=Expand[CSF2[False,sigma][expr,i,ic,False]/.rest_.(sig:(sigma[a_,i,j_]|sigma[a_,j_,i]))covd_Symbol?CovDQ[inds__][expr1_]:>rest covd[inds][CSF2[True,sigma][sig expr1,i,ic,False]]/;IsIndexOf[expr1,ic]&&IsIndexOf[expr1,ChangeIndex[j]]&&SolderingFormOfSpinCovD[covd]===sigma];
(* For other types of indices, do nothing *)
CSF2[_,_][expr_,_,_,False]:=expr;


(* Generalize some Q-functions *)
SpinorTMP/:HasDaggerCharacterQ[SpinorTMP[tensor_,sigma_,___]]:=HasDaggerCharacterQ[tensor];
SpinorTMP/:xTensorQ[SpinorTMP[tensor_,sigma_,___]]:=xTensorQ[tensor];
TensorTMP/:xTensorQ[TensorTMP[spinor_,sigma_,___]]:=xTensorQ[spinor];
(* IsIndexOf *)
SpinorTMP/:IsIndexOf[SpinorTMP[__][inds__],ind_,_]:=MemberQ[{inds},ind];
TensorTMP/:IsIndexOf[TensorTMP[__][inds__],ind_,_]:=MemberQ[{inds},ind];
(* Recursion *)
SpinorTMP[SpinorTMP[tensor_,sigma_,rules1___],sigma_,rules2___]:=SpinorTMP[tensor,sigma,rules1,rules2];
TensorTMP[TensorTMP[spinor_,sigma_,rules1___],sigma_,rules2___]:=TensorTMP[spinor,sigma,rules1,rules2];
SpinorTMP[SpinorTMP[__],__]:=Throw@Message[ContractSolderingForm::error,"Cannot contract two different soldering forms on the same tensor."];
TensorTMP[TensorTMP[__],__]:=Throw@Message[ContractSolderingForm::error,"Cannot contract two different soldering forms on the same spinor."];


ArrangeSpinTMP[SpinorTMP[tensor_,sigma_,rules___][spinds___]]:=With[{spinor=SpinorOfTensor[tensor,sigma]},
If[!xTensorQ[spinor],DefSpinorOfTensor[spinor[spinds],Apply[tensor,DummyIn/@SlotsOfTensor[tensor]],sigma]];
SpinorSign[spinor,rules][spinds]spinor[spinds]];


ArrangeSpinTMP[TensorTMP[spinor_,sigma_,rules___][tinds___]]:=With[{tensor=TensorOfSpinor[spinor,sigma]},
If[!xTensorQ[tensor],DefTensorOfSpinor[tensor[tinds],Apply[spinor,DummyIn/@SlotsOfTensor[spinor]],sigma]];
TensorSign[spinor,rules][tinds]tensor[tinds]];


(* Derivatives: correct character is covariant *)
CovDSpinSign[i_,j_]:=If[UpIndexQ[i],-1,1]If[UpIndexQ[j],-1,1];
(* Transforming spinor into tensor *)
TensorSign[spinor_][___]:=1;
TensorSign[spinor_,rules__][tinds___]:=Apply[SpinorSign[spinor,rules],IndexList[tinds]/.{rules}];
(* Transforming tensor into spinor *)
SpinorSign[spinor_][___]:=1;
SpinorSign[spinor_,rules__][spinds___]:=With[{repinds=Last/@{rules}},
Inner[checkVB,xAct`xTensor`Private`SignedVBundleOfIndex/@repinds,SlotsOfTensor[spinor][[Flatten[Position[{spinds},#]&/@repinds]]],Times]];
(* Check vbundles are correct *)
checkVB[vb_,-vb_]:=-1;
checkVB[-vb_,vb_]:=-1;
checkVB[vb_,vb_]:=1;
checkVB[_,_]:=Throw@Message[ContractSolderingForm::error,"Internal inconsistency. Tell JMM."];


(* To four arguments *)
SeparateSolderingForm[args___][expr_]:=SeparateSolderingForm[args][expr,All];
SeparateSolderingForm[][expr_,inds_]:=SeparateSolderingForm[$SolderingForms,AIndex][expr,inds];
SeparateSolderingForm[sigma_][expr_,inds_]:=SeparateSolderingForm[sigma,AIndex][expr,inds];
(* Four arguments *)
SeparateSolderingForm[list_List,basis_][expr_,inds_]:=Fold[SeparateSolderingForm[#2,basis][#1,inds]&,expr,list];
SeparateSolderingForm[sigma_Symbol,basis_][expr_,All]:=SeparateSolderingForm[sigma,basis][expr,IndicesOf[]];
SeparateSolderingForm[sigma_Symbol,basis_][expr_,vb_Symbol?VBundleQ]:=SeparateSolderingForm[sigma,basis][expr,IndicesOf[vb]];
SeparateSolderingForm[sigma_Symbol,basis_][expr_,covd_Symbol?CovDQ]:=SeparateSolderingForm[sigma,basis][expr,IndicesOf[covd]];
SeparateSolderingForm[sigma_Symbol,basis_][expr_,ind_?GIndexQ]:=SeparateSolderingForm[sigma,basis][expr,IndexList[ind]];
(* Thread over sums, before using IndicesOf *)
SeparateSolderingForm[sigma_Symbol,basis_][expr_Plus,inds_]:=SeparateSolderingForm[sigma,basis][#,inds]&/@expr;
SeparateSolderingForm[sigma_Symbol,basis_][expr_,f_IndicesOf]:=SeparateSolderingForm[sigma,basis][expr,f[expr]];
(* Expand list of indices *)
SeparateSolderingForm[sigma_Symbol,basis_][expr_,list_IndexList]:=RemoveTMP@Fold[SSF1[sigma,basis],expr,FindPairs[expr,{VBundleOfSolderingForm[sigma]},list]];
(* Errors *)
SeparateSolderingForm[x__][_,_IndexList]:=Throw@Message[SeparateSolderingForm::invalid,{x},"sigma or basis info"];
SeparateSolderingForm[_,_][_,x__]:=Message[SeparateSolderingForm::"argrx",SeparateSolderingForm,2+Length[{x}],2];
Protect[SeparateSolderingForm];


SSF1[sigma_,basis_][expr_,pair_Pair]:=SSFInner[sigma,basis][expr,pair];
SSF1[sigma_,basis_][0,AnyIndices]:=0;
SSF1[sigma_,basis_][expr_,index_]:=SSFTangent[sigma,basis][expr,index]/;DaggerIndex[index]===index;
SSF1[__][expr_,_]:=expr;


SSFTangent[sigma_,basis_][expr_,index_]:=With[{ivb=VBundleOfIndex[index],svb=VBundleOfSolderingForm[sigma]},
If[ivb=!=TangentBundleOfManifold@BaseOfVBundle@svb,Throw@Message[SeparateSolderingForm::invalid,sigma,"soldering form for index "<>ToString[index]]];
expr/.{
tensor_?xTensorQ[a___,index,b___]:>Module[{A=If[UpIndexQ[index],1,-1]DummyIn[svb,basis],Ad},
Ad=DaggerIndex[A];
If[HasDaggerCharacterQ[tensor],
SpinorTMP[tensor,sigma,index:>Sequence[Ad,A]][a,Ad,A,b],
SpinorTMP[tensor,sigma,index:>Sequence[A,Ad]][a,A,Ad,b]
]sigma[index,-A,-Ad]
]/;tensor=!=sigma,
covd_Symbol?CovDQ[a___,index,b___][expr1_]:>Module[{A=If[UpIndexQ[index],1,-1]DummyIn[svb,basis],Ad},
Ad=DaggerIndex[A];
CovDSpinSign[A,Ad]covd[a,A,Ad,b][expr1]sigma[index,-A,-Ad]]
}
];


SSFInner[sigma_,basis_][expr_,Pair[i1_,i2_]]:=With[{tbundle=TangentBundleOfManifold@BaseOfVBundle@VBundleOfIndex[i1],ii1=If[HasDaggerCharacterQ[i2],i1,i2],ii2=If[HasDaggerCharacterQ[i2],i2,i1]},
expr/.{
spinor_?xTensorQ[a___,ii1,ii2,b___]:>Module[{dummy=If[UpIndexQ[ii1],1,-1]DummyIn[tbundle,basis]},TensorTMP[spinor,sigma][a,dummy,b]sigma[-dummy,ii1,ii2]]/;spinor=!=sigma,
spinor_?xTensorQ[a___,ii2,ii1,b___]:>Module[{dummy=If[UpIndexQ[ii1],1,-1]DummyIn[tbundle,basis]},TensorTMP[spinor,sigma][a,dummy,b]sigma[-dummy,ii1,ii2]]/;spinor=!=sigma,
covd_Symbol?CovDQ[ii1,ii2][expr1_]:>Module[{dummy=If[UpIndexQ[ii1],1,-1]DummyIn[tbundle,basis]},covd[dummy][expr1]sigma[-dummy,ii1,ii2]]
}];


(* We should check that these are indeed spin-indices *)
IrreducibleDecomposition[tensor_Symbol?xTensorQ[inds__]]:=IrreducibleDecomposition[tensor[inds],First@Union@Sort[VBundleOfIndex/@IndexList@inds]];
(* Scalar case *)
IrreducibleDecomposition[tensor_Symbol?xTensorQ[],_]:=tensor[];
(* Vector case *)
IrreducibleDecomposition[tensor_Symbol?xTensor[a_],_]:=tensor[a];
(* General case: create TF tensor and separate VB and VBdagger *)
IrreducibleDecomposition[tensor_Symbol?xTensorQ[inds__],spinVB_]:=With[{pos1=SlotsOfVBundle[tensor[inds],spinVB],pos2=SlotsOfVBundle[tensor[inds],Dagger@spinVB],epsilon=First@MetricsOfVBundle@spinVB,tft=SymbolJoin["TF",tensor]},
If[!xTensorQ[tft],
DefTensor[tft[LI["TF"],AnyIndices@spinVB,AnyIndices@Dagger@spinVB],BaseOfVBundle[spinVB],Dagger->Complex,Master->tensor,ProtectNewSymbol->False]
];
SymmetryGroupOfTensor[tft[inds1__]]^:=JoinSGS[Symmetric[SlotsOfVBundle[tft[inds1 ],spinVB]],Symmetric[SlotsOfVBundle[tft[inds1],Dagger@spinVB]]];
tft[___,a_,___,-a_,___]:=0; 
tft[___,-a_,___,a_,___]:=0;Apply[Plus,DecoBuild[tft,{inds},epsilon,Dagger@epsilon]/@DecoOuter[pos1,pos2,Length[{inds}]]]
];


SlotsOfVBundle[list_,vbundle_]:=Flatten@Position[list,_?(AIndexQ[#,vbundle]&),{1}];


(* Given a list of slots, return all possible pairs, sorted *)
DecoPairs[list_]:=Union@Map[Sort,Partition[#,2]&/@Permutations[list],2];
(* Given a list of slots, return all possibe groups of 2n slots *)
DecoGroups[list_]:=Flatten[Table[DecoPairs/@Subsets[list,{n}],{n,0,Length@list,2}],2];
(* Given spin slots and spindag slots, return all combinations and the complementary slots *)
DecoOuter[list1_,list2_,length_]:=Flatten[Outer[DecoArrange[length],DecoGroups[list1],DecoGroups[list2],1],1];
DecoArrange[n_][list1_,list2_]:={list1,list2,Complement[Range[n],Flatten@list1,Flatten@list2]};
(* Construct actual TFT tensor and product of epsilons *)
DecoBuild[tft_,inds_,eps_,epsdag_][{list1_,list2_,list_}]:=
tft[LI@Join[list1,list2],Sequence@@(inds[[list]])]Times@@Apply[eps,Part[inds,#]&/@list1,1]Times@@Apply[epsdag,Part[inds,#]&/@list2,1];


Options[DefSpinCovD]:={
Torsion->False,
FromMetric->Null,
ExtendedFrom->Null,
Master->Null,
ProtectNewSymbol->$ProtectNewSymbols,
DefInfo->{"spin covariant derivative",""}
};
$SpinCovDs:=Apply[Join,SpinCovDsOfSolderingForm/@$SolderingForms];
DefSpinCovD[covd_[-a_],sigma_,symbols_,options:OptionsPattern[]]:=Catch@Module[{metric,ef,newsymbols,a1,A1,A1d,B1,B1d},
{a1}=GetIndicesOfVBundle[VBundleOfIndex[a],1];
{A1,B1}=GetIndicesOfVBundle[VBundleOfSolderingForm[sigma],2];
{A1d,B1d}=DaggerIndex/@{A1,B1};
{metric,ef}=OptionValue[{FromMetric,ExtendedFrom}];

(* If extended, the properties of covd are those of ef (forget options) *)
If[ef=!=Null,metric=MetricOfCovD[ef]];

(* Check metric argument *)
If[metric=!=Null,
If[BaseOfVBundle@VBundleOfMetric[metric]=!=BaseOfVBundle@VBundleOfSolderingForm[sigma],Throw@Message[DefSpinCovD::error,"Incompatible vbundles of metric and soldering form."]];
(* Association to a frozen metric is removed 
If[xAct`xTensor`Private`FrozenMetricQ[metric],Message[DefSpinCovD::error,"A frozen metric cannot be used."];metric=Null]*)
];

(* Define derivative. How do we pass the options? *)
DefCovD[covd[-a],VBundleOfSolderingForm[sigma],symbols,FilterRules[{options},Options[DefCovD]]];
SpinCovDQ[covd]^=True;
(* Relations between the covariant derivative and the soldering form *)
SolderingFormOfSpinCovD[covd]^=sigma;
xUpAppendTo[SpinCovDsOfSolderingForm[sigma],covd];

(* If ef===Null then use the trick of extending from covd *)
If[ef===Null,ef=covd];

(* Construct associated curvature spinors *)
ConstructRTSpinors[covd,ef,sigma,metric,options];

(* Define associated box operators *)
DefBox[covd];

(* Compatibility with the spin structure *)
If[metric===Null,
covd[__][sigma[b_Symbol,-F_,-G_]]:=0;
covd[__][sigma[-b_,F_Symbol,G_Symbol]]:=0,
covd[__][sigma[b_,F_,G_]]:=0
];

(* Definitions as 2-index derivative *)
xAct`xTensor`Private`MakeLinearDerivative[{covd[F_,G_],covd[F,G]},True];

(* Relations between 2-index derivative and spacetime derivative *)
SpinorToTensor[covd,sigma]:=MakeRule[{covd[A1,A1d]@expr_,sigma[a1,A1,A1d]covd[-a1]@expr},UseSymmetries->False,Evaluate->True];
TensorToSpinor[covd,sigma]:=MakeRule[{covd[a1]@expr_,sigma[a1,A1,A1d]covd[-A1,-A1d]@expr},UseSymmetries->False,Evaluate->True];

(* Behaviour under complex conjugation: "Hermitian" *)
xAct`xTensor`Private`DaggerCovD[covd[inds__]]^:=Apply[covd,TransposeDagger@DaggerIndex@IndexList[inds]];

];
SetNumberOfArguments[DefSpinCovD,{3,Infinity}];
Protect[DefSpinCovD];


UndefSpinCovD[covd_]:=(
If[FreeQ[$SpinCovDs,covd],Throw@Message[SpinCovDs::unknown,"spin covd",covd]];
Undef/@Flatten[VisitorsOf/@ServantsOf[covd]];
UndefCovD[covd];
);
SetNumberOfArguments[UndefSpinCovD,1];
Protect[DefSpinCovD];


SpinCovDQ[covd_]:=False;


Unprotect[FirstDerQ];
FirstDerQ[_Symbol?SpinCovDQ[__]]:=True;
Protect[FirstDerQ];


GiveOutputString[Chi,covd_]:=StringJoin["\[CapitalChi]","[",SymbolOfCovD[covd][[2]],"]"];
GiveOutputString[Phi,covd_]:=StringJoin["\[CapitalPhi]","[",SymbolOfCovD[covd][[2]],"]"];
GiveOutputString[Psi,covd_]:=StringJoin["\[CapitalPsi]","[",SymbolOfCovD[covd][[2]],"]"];
GiveOutputString[Lambda,covd_]:=StringJoin["\[CapitalLambda]","[",SymbolOfCovD[covd][[2]],"]"];


GiveOutputString[Omega,covd_]:=StringJoin["\[CapitalOmega]","[",SymbolOfCovD[covd][[2]],"]"];


Chi[covd_Symbol?CovDQ]:=GiveSymbol[Chi,covd];
Phi[covd_Symbol?CovDQ]:=GiveSymbol[Phi,covd];
Psi[covd_Symbol?CovDQ]:=GiveSymbol[Psi,covd];
Lambda[covd_Symbol?CovDQ]:=GiveSymbol[Lambda,covd];
Omega[covd_Symbol?CovDQ]:=GiveSymbol[Omega,covd];


compumessage[covd_,tensor_]:=Null;


xAct`xTensor`Private`DefSign[$ChiSign,"\!\(\*SubscriptBox[\(s\), \(\[CapitalChi]\)]\)",1];
xAct`xTensor`Private`DefSign[$PhiSign,"\!\(\*SubscriptBox[\(s\), \(\[CapitalPhi]\)]\)",1];
xAct`xTensor`Private`DefSign[$PsiSign,"\!\(\*SubscriptBox[\(s\), \(\[CapitalPsi]\)]\)",1];
xAct`xTensor`Private`DefSign[$LambdaSign,"\!\(\*SubscriptBox[\(s\), \(\[CapitalLambda]\)]\)",1];
xAct`xTensor`Private`DefSign[$OmegaSign,"\!\(\*SubscriptBox[\(s\), \(\[CapitalOmega]\)]\)",1];


ConstructRTSpinors[covd_,ef_,sigma_,metric_,options:OptionsPattern[]]:=With[{
RiemannName=AddSpinorPrefix[Riemann[ef],SpinorPrefix[sigma]],
RicciName=AddSpinorPrefix[Ricci[ef],SpinorPrefix[sigma]],
WeylName=If[metric=!=Null,AddSpinorPrefix[Weyl[ef],SpinorPrefix[sigma]]],
TFRicciName=If[metric=!=Null,AddSpinorPrefix[TFRicci[ef],SpinorPrefix[sigma]]],

TorsionName=If[TorsionQ[covd],AddSpinorPrefix[Torsion[ef],SpinorPrefix[sigma]]],

FRiemannName=AddSpinorPrefix[FRiemann[covd],SpinorPrefix[sigma]],

ChiName=Chi[covd],
PhiName=Phi[covd],
PsiName=If[metric=!=Null,Psi[covd]],
LambdaName=If[metric=!=Null,Lambda[covd]],

OmegaName=If[TorsionQ[covd],Omega[covd]],

vbundle=VBundleOfSolderingForm[sigma],
vbundledag=Dagger@VBundleOfSolderingForm[sigma],
base=BaseOfVBundle@VBundleOfSolderingForm[sigma],
tbundle=TangentBundleOfSolderingForm[sigma],
eps=SpinMetricOfSolderingForm[sigma],
epsdag=Dagger@SpinMetricOfSolderingForm[sigma],

LeviCivitaQ=metric=!=Null&&!TorsionQ[covd],
LeviCivitaTorsionQ=metric=!=Null&&TorsionQ[covd]
},

Module[{A,B,F,G,Ad,Bd,Fd,Gd,a,b,c,d,PsiNamedag,FRiemannNamedag,ChiNamedag,PhiNamedag,OmegaNamedag,MakeRuleOptions},
{A,B,F,G}=GetIndicesOfVBundle[vbundle,4,{}];
{Ad,Bd,Fd,Gd}=DaggerIndex/@{A,B,F,G};
{a,b,c,d}=GetIndicesOfVBundle[tbundle,4,{}];

(* Change temporarily default options for MakeRule *)
MakeRuleOptions=Options[MakeRule];
SetOptions[MakeRule,UseSymmetries->False,ContractMetrics->False];

(* Definition of curvature spinors (we check that the original inner curvature is different from zero *)
If[FRiemann[covd][-a,-b,-F,-G]=!=0,
DefSpinorOfTensor[FRiemannName[-A,-Ad,-B,-Bd,-F,-G],FRiemann[covd][-a,-b,-F,-G],sigma,Dagger->Complex,options];
FRiemannNamedag=Dagger[FRiemannName];

DefTensor[ChiName[-A,-B,-F,-G],base,Which[LeviCivitaTorsionQ,StrongGenSet[{1,3},GenSet[xAct`xPerm`Cycles[{1,2}],xAct`xPerm`Cycles[{3,4}]]],LeviCivitaQ,StrongGenSet[{1,3},GenSet[xAct`xPerm`Cycles[{1,2}],xAct`xPerm`Cycles[{3,4}],xAct`xPerm`Cycles[{1,3},{2,4}]]],True,Symmetric[{3,4}]],Dagger->Complex,PrintAs:>GiveOutputString[Chi,covd],Master->covd,FilterRules[{options},Options[DefTensor]],DefInfo->{"curvature spinor",""}];
ChiNamedag:=Dagger[ChiName];

DefTensor[PhiName[-A,-B,-Fd,-Gd],base,If[LeviCivitaQ,StrongGenSet[{1,3},GenSet[xAct`xPerm`Cycles[{1,2}],xAct`xPerm`Cycles[{3,4}]]],Symmetric[{3,4}]],If[LeviCivitaQ,Dagger->Hermitian,Dagger->Complex],PrintAs:>GiveOutputString[Phi,covd],Master->covd,FilterRules[{options},Options[DefTensor]],DefInfo->{"curvature spinor",""}];
PhiNamedag=Dagger[PhiName];
];
(*Computation of the decomposition rules for the curvature spinors*)
compumessage[covd,FRiemann];
If[xTensorQ@FRiemannName,
covd/:DecompositionRules[covd,FRiemann]=Flatten[{MakeRule[{FRiemannName[-A,-Ad,-B,-Bd,-F,-G],$ChiSign ChiName[-F,-G,-A,-B]epsdag[-Ad,-Bd]+eps[-A,-B]$PhiSign PhiName[-F,-G,-Ad,-Bd]}],MakeRule[{Evaluate@FRiemannNamedag[-Ad,-A,-Bd,-B,-Fd,-Gd],$ChiSign ChiNamedag[-Fd,-Gd,-Ad,-Bd]eps[-A,-B]+epsdag[-Ad,-Bd]$PhiSign PhiNamedag[-Fd,-Gd,-A,-B]}]}]
];

If[LeviCivitaQ,

DefTensor[LambdaName[],base,Dagger->Real,PrintAs:>GiveOutputString[Lambda,covd],Master->covd,FilterRules[{options},Options[DefTensor]],DefInfo->{"spinor scalar curvature",""}];

DefTensor[PsiName[-A,-B,-F,-G],base,Symmetric[{1,2,3,4}],Dagger->Complex,PrintAs:>GiveOutputString[Psi,covd],Master->covd,FilterRules[{options},Options[DefTensor]],DefInfo->{"Weyl spinor",""}];
PsiNamedag=Dagger[PsiName];

compumessage[covd,Chi];
(*SymmetryGroupOfTensor[ChiName]^=StrongGenSet[{1,3},GenSet[Cycles[{1,2}],Cycles[{3,4}]]];*)
covd/:DecompositionRules[covd,Chi]=Flatten[{MakeRule[{ChiName[-A,-B,-F,-G],($LambdaSign/$ChiSign) LambdaName[](eps[-A,-G]eps[-B,-F]+eps[-A,-F]eps[-B,-G])+(($PsiSign/$ChiSign)) PsiName[-A,-B,-F,-G]}],MakeRule[{Evaluate[ChiNamedag[-Ad,-Bd,-Fd,-Gd]], ($LambdaSign/$ChiSign)LambdaName[](epsdag[-Ad,-Gd]epsdag[-Bd,-Fd]+epsdag[-Ad,-Fd]epsdag[-Bd,-Gd])+(($PsiSign/$ChiSign))PsiNamedag[-Ad,-Bd,-Fd,-Gd]}]}];

];

(* This part will be executed only if the Torsion spinor has not been defined *)
If[xTensorQ[TorsionName],
If[$DefInfoQ,Print["** DefSpinCovD:  Torsion spinor for tangent derivative ",ef," already defined"]],

DefSpinorOfTensor[TorsionName[-A,-Ad,-B,-Bd,-F,-Fd],Torsion[ef][-a,-b,-c],sigma,options];
];

(* Define the torsion spinor *)
If[TorsionQ@covd,
DefTensor[OmegaName[-Ad,-A,-B,-F],base,Symmetric[{3,4}],Dagger->Complex,PrintAs:>GiveOutputString[Omega,covd],Master->covd,FilterRules[{options},Options[DefTensor]],DefInfo->{"torsion spinor",""}];

OmegaNamedag=Dagger[OmegaName];

covd/:DecompositionRules[covd,Torsion]=
MakeRule[{TorsionName[-A,-Ad,-B,-Bd,-F,-Fd],epsdag[-Bd,-Fd]$OmegaSign OmegaName[-Ad,-A,-B,-F]+eps[-B,-F]$OmegaSign OmegaNamedag[-A,-Ad,-Bd,-Fd]}];
];

(* The remaining part will be executed only if the Riemann spinor has not been defined and if the Riemann and Ricci tensors do not vanish *)
If[xTensorQ[RiemannName]&&(Riemann[ef][-a,-b,-c,-d]=!=0)&&(Ricci[ef][-a,-b]=!=0),
If[$DefInfoQ,Print["** DefSpinCovD:  Curvature spinors for tangent derivative ",ef," already defined"]],

DefSpinorOfTensor[RiemannName[-A,-Ad,-B,-Bd,-F,-Fd,-G,-Gd],Riemann[ef][-a,-b,-c,-d],sigma,options];

DefSpinorOfTensor[RicciName[-A,-Ad,-B,-Bd],Ricci[ef][-a,-b],sigma,options];
If[!LeviCivitaQ&&xTensorQ@RiemannName,
compumessage[covd,Riemann];
covd/:DecompositionRules[covd,Riemann]=MakeRule[{RiemannName[-A,-Ad,-B,-Bd,-F,-Fd,-G,-Gd],eps[-F,-G]FRiemannNamedag[-Ad,-A,-Bd,-B,-Gd,-Fd]+epsdag[-Fd,-Gd]FRiemannName[-A,-Ad,-B,-Bd,-G,-F]}]];
If[LeviCivitaQ,

PsiNamedag=Dagger[PsiName];

DefSpinorOfTensor[WeylName[-A,-Ad,-B,-Bd,-F,-Fd,-G,-Gd],Weyl[ef][-a,-b,-c,-d],sigma,options];

DefSpinorOfTensor[TFRicciName[-A,-Ad,-B,-Bd],TFRicci[ef][-a,-b],sigma,options];

compumessage[covd,Riemann];
covd/:DecompositionRules[covd,Riemann]=MakeRule[{RiemannName[-A,-Ad,-B,-Bd,-F,-Fd,-G,-Gd],-2(-eps[-A,-F]eps[-B,-G]epsdag[-Ad,-Fd]epsdag[-Bd,-Gd]+eps[-A,-G]eps[-B,-F]epsdag[-Ad,-Gd]epsdag[-Bd,-Fd])$LambdaSign LambdaName[]-eps[-G,-F]epsdag[-Ad,-Bd]$PhiSign PhiName[-A,-B,-Gd,-Fd]-eps[-A,-B]epsdag[-Gd,-Fd]$PhiSign PhiName[-G,-F,-Ad,-Bd]-epsdag[-Ad,-Bd]epsdag[-Gd,-Fd]$PsiSign PsiName[-A,-B,-G,-F]-eps[-A,-B]eps[-G,-F]$PsiSign PsiNamedag[-Ad,-Bd,-Gd,-Fd]}];

compumessage[covd,Ricci];
covd/:DecompositionRules[covd,Ricci]=MakeRule[{RicciName[-A,-Ad,-B,-Bd],6$LambdaSign LambdaName[]eps[-A,-B]epsdag[-Ad,-Bd]-2$PhiSign PhiName[-A,-B,-Ad,-Bd]}];

compumessage[covd,TFRicci];
covd/:DecompositionRules[covd,TFRicci]=MakeRule[{TFRicciName[-A,-Ad,-B,-Bd],-2$PhiSign PhiName[-A,-B,-Ad,-Bd]}];

(* We use the RicciScalar and not its spinor *)
compumessage[covd,RicciScalar];
covd/:DecompositionRules[covd,RicciScalar]=MakeRule[{Evaluate[RicciScalar[ef][]],24$LambdaSign LambdaName[]}];

compumessage[covd,Weyl];
covd/:DecompositionRules[covd,Weyl]=MakeRule[{WeylName[-A,-Ad,-B,-Bd,-F,-Fd,-G,-Gd],-epsdag[-Ad,-Bd]epsdag[-Gd,-Fd]$PsiSign PsiName[-A,-B,-G,-F]-eps[-A,-B]eps[-G,-F]$PsiSign PsiNamedag[-Ad,-Bd,-Gd,-Fd]}];

]
];
(* Return to original options *)
Options[MakeRule]=MakeRuleOptions;

]
];


Decomposition[expr_]:=Decomposition[expr,{FRiemann,Riemann,Ricci,TFRicci,RicciScalar,Weyl,Torsion}];
Decomposition[expr_,object_]:=Decomposition[expr,object,$SpinCovDs];
Decomposition[expr_,objects_List,covd_]:=Fold[Decomposition[#1,#2,covd]&,expr,objects];
Decomposition[expr_,object_,covds_List]:=Fold[Decomposition[#1,object,#2]&,expr,covds];
Decomposition[expr_,object_,covd_]:=expr/.DecompositionRules[covd,object];
DecompositionRules[covd_,object_]:={};
SetNumberOfArguments[Decomposition,{1,3}];
Protect[Decomposition];


DefBox[covd_Symbol]:=With[{boxcd=SymbolJoin["Box",covd]},
CovDQ[boxcd]^=True;
AppendTo[xAct`xTensor`Private`$MultiIndexCovDs,boxcd];
xAct`xTensor`Private`MakeLinearDerivative[{boxcd[A_,B_],boxcd[A,B]},True];
SymmetryGroupOfCovD[boxcd]^=Symmetric[{1,2},xAct`xPerm`Cycles];
ManifoldOfCovD[boxcd]^=ManifoldOfCovD[covd];
VBundlesOfCovD[boxcd]^=VBundlesOfCovD[covd];
DependenciesOfCovD[boxcd]^=DependenciesOfCovD[covd];
CovDOfBox[boxcd]^=covd;
boxcd/:Dagger[boxcd[A_,B_][expr_]]:=boxcd[DaggerIndex[A],DaggerIndex[B]][Dagger[expr]];
SymbolOfCovD[boxcd]^={First[SymbolOfCovD[covd]],StringJoin["\[EmptySquare]","[",Part[SymbolOfCovD@covd,2],"]"]};
xAct`xTensor`Private`SymbolRelations[boxcd,covd,{}];
Protect[boxcd];
];


BoxToCovD[expr_,boxcd_]:=With[{
cd=CovDOfBox@boxcd,
spin=VBundlesOfCovD[boxcd][[2]],spindag=VBundlesOfCovD[boxcd][[3]]},
expr/.{boxcd[A_,B_]@L_:>With[{Cdag=DummyIn[spindag]},xAct`xTensor`Symmetrize[cd[A,-Cdag]@cd[B,Cdag]@L,{A,B}]]/;ABIndexQ[A,spin]&&ABIndexQ[B,spin],boxcd[A_,B_]@L_:>With[{C=DummyIn[spin]},
xAct`xTensor`Symmetrize[cd[-C,A]@cd[C,B]@L,{A,B}]]/;ABIndexQ[A,spindag]&&ABIndexQ[B,spindag]}
];
SetNumberOfArguments[BoxToCovD,2];
Protect[BoxToCovD];


BoxToCurvature[expr_,boxcd_]:=With[{spin=VBundlesOfCovD[boxcd][[2]],spindag=VBundlesOfCovD[boxcd][[3]]},expr/.boxcd[A_,B_]@L_:>addCurvatureBox[L,CovDOfBox@boxcd,{A,B},List@@FindFreeIndices[L],spin,spindag]];
SetNumberOfArguments[BoxToCurvature,2];
Protect[BoxToCurvature];


addCurvatureBox[expr_,covd_,{A_,B_},frees_,vb_,vbdag_]:=With[{dummy1=DummyIn[vb],dummy2=DummyIn[vbdag],vbQ=xAct`xTensor`Private`VBundleIndexQ[vb],vbdagQ=xAct`xTensor`Private`VBundleIndexQ[vbdag],vbpmQ=xAct`xTensor`Private`VBundleIndexPMQ[vb],vbpmdagQ=xAct`xTensor`Private`VBundleIndexPMQ[vbdag],chicd=Chi[covd],phicd=Phi[covd],omegacd=If[TorsionQ[covd],Omega[covd],Zero]},
Which[ABIndexQ[A,vb]&&ABIndexQ[B,vb]&&TorsionQ@covd,-$ChiSign $RiemannSign Plus@@((chicd[#,-dummy1,A,B] ReplaceIndex[expr,#->dummy1]&)/@Select[frees,vbQ])+$ChiSign $RiemannSign Plus@@((chicd[dummy1,#,A,B] ReplaceIndex[expr,#->-dummy1]&)/@Complement[Select[frees,vbpmQ],Select[frees,vbQ]])-$PhiSign $RiemannSign Plus@@((Dagger[phicd][#,-dummy2,A,B] ReplaceIndex[expr,#->dummy2]&)/@Select[frees,vbdagQ])+$PhiSign $RiemannSign Plus@@((Dagger[phicd][dummy2,#,A,B] ReplaceIndex[expr,#->-dummy2]&)/@Complement[Select[frees,vbpmdagQ],Select[frees,vbdagQ]])-$TorsionSign $OmegaSign omegacd[dummy2,dummy1,A,B]covd[-dummy1,-dummy2]@expr,
ABIndexQ[A,vb]&&ABIndexQ[B,vb]&&!TorsionQ@covd,
-$ChiSign $RiemannSign Plus@@((chicd[-dummy1,#,A,B] ReplaceIndex[expr,#->dummy1]&)/@Select[frees,vbpmQ])-$PhiSign $RiemannSign Plus@@((Dagger[phicd][-dummy2,#,A,B] ReplaceIndex[expr,#->dummy2]&)/@Select[frees,vbpmdagQ]),
ABIndexQ[A,vbdag]&&ABIndexQ[B,vbdag]&&TorsionQ@covd,
-$ChiSign $RiemannSign Plus@@((Dagger[chicd][#,-dummy2,A,B] ReplaceIndex[expr,#->dummy2]&)/@Select[frees,vbdagQ])+$ChiSign $RiemannSign Plus@@((Dagger[chicd][dummy2,#,A,B] ReplaceIndex[expr,#->-dummy2]&)/@Complement[Select[frees,vbpmdagQ],Select[frees,vbdagQ]])-$PhiSign $RiemannSign Plus@@((phicd[#,-dummy1,A,B] ReplaceIndex[expr,#->dummy1]&)/@Select[frees,vbQ])+$PhiSign $RiemannSign Plus@@((phicd[dummy1,#,A,B] ReplaceIndex[expr,#->-dummy1]&)/@Complement[Select[frees,vbpmQ],Select[frees,vbQ]])-$TorsionSign $OmegaSign Dagger[omegacd][dummy1,dummy2,A,B]covd[-dummy1,-dummy2]@expr,
ABIndexQ[A,vbdag]&&ABIndexQ[B,vbdag]&&!TorsionQ@covd,
-$ChiSign $RiemannSign Plus@@((Dagger[chicd][-dummy2,#,A,B] ReplaceIndex[expr,#->dummy2]&)/@Select[frees,vbpmdagQ])-$PhiSign $RiemannSign Plus@@((phicd[-dummy1,#,A,B] ReplaceIndex[expr,#->dummy1]&)/@Select[frees,vbpmQ])
]

];


SortSpinCovDs[expr1_,cd_?CovDQ]:=expr1/.cd[A_,A\[Dagger]_]@cd[B_,B\[Dagger]_]@expr_:>cd[B,B\[Dagger]]@cd[A,A\[Dagger]]@expr+SpinMetricOfSolderingForm[SolderingFormOfSpinCovD@cd][A,B] SymbolJoin["Box",cd][A\[Dagger],B\[Dagger]]@expr+Dagger[SpinMetricOfSolderingForm[SolderingFormOfSpinCovD@cd]][A\[Dagger],B\[Dagger]] SymbolJoin["Box",cd][A,B]@expr/;DisorderedPairQ[A,B];


End[]
EndPackage[]



