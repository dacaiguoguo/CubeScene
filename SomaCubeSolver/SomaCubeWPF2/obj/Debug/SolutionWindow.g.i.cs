﻿#pragma checksum "..\..\SolutionWindow.xaml" "{ff1816ec-aa5e-4d10-87f7-6f4963833460}" "394A0A1B7A9123C0B4FB8EC49DC1A50E73FD0C4F"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using SomaCubeWPF2;
using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace SomaCubeWPF2 {
    
    
    /// <summary>
    /// SolutionWindow
    /// </summary>
    public partial class SolutionWindow : System.Windows.Window, System.Windows.Markup.IComponentConnector {
        
        
        #line 28 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.ListBox lbSolutions;
        
        #line default
        #line hidden
        
        
        #line 34 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnPrevious;
        
        #line default
        #line hidden
        
        
        #line 37 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnNext;
        
        #line default
        #line hidden
        
        
        #line 41 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Label lblItemNumber;
        
        #line default
        #line hidden
        
        
        #line 45 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnGoto;
        
        #line default
        #line hidden
        
        
        #line 48 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox tbGoto;
        
        #line default
        #line hidden
        
        
        #line 51 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.ProgressBar pbStatus;
        
        #line default
        #line hidden
        
        
        #line 55 "..\..\SolutionWindow.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnClose;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/SomaCubeWPF2;component/solutionwindow.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\SolutionWindow.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            this.lbSolutions = ((System.Windows.Controls.ListBox)(target));
            
            #line 28 "..\..\SolutionWindow.xaml"
            this.lbSolutions.SelectionChanged += new System.Windows.Controls.SelectionChangedEventHandler(this.Selected_Click);
            
            #line default
            #line hidden
            return;
            case 2:
            this.btnPrevious = ((System.Windows.Controls.Button)(target));
            
            #line 34 "..\..\SolutionWindow.xaml"
            this.btnPrevious.Click += new System.Windows.RoutedEventHandler(this.BtnPrevious_Click);
            
            #line default
            #line hidden
            return;
            case 3:
            this.btnNext = ((System.Windows.Controls.Button)(target));
            
            #line 37 "..\..\SolutionWindow.xaml"
            this.btnNext.Click += new System.Windows.RoutedEventHandler(this.BtnNext_Click);
            
            #line default
            #line hidden
            return;
            case 4:
            this.lblItemNumber = ((System.Windows.Controls.Label)(target));
            return;
            case 5:
            this.btnGoto = ((System.Windows.Controls.Button)(target));
            
            #line 45 "..\..\SolutionWindow.xaml"
            this.btnGoto.Click += new System.Windows.RoutedEventHandler(this.BtnGoTo_Click);
            
            #line default
            #line hidden
            return;
            case 6:
            this.tbGoto = ((System.Windows.Controls.TextBox)(target));
            return;
            case 7:
            this.pbStatus = ((System.Windows.Controls.ProgressBar)(target));
            return;
            case 8:
            this.btnClose = ((System.Windows.Controls.Button)(target));
            
            #line 55 "..\..\SolutionWindow.xaml"
            this.btnClose.Click += new System.Windows.RoutedEventHandler(this.BtnClose_Click);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
    }
}

