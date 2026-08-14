using System;
using UnityEngine;

namespace EggRescue
{
    public static class GameEvents
    {
        public static event Action<string> VariableChanged;
        public static event Action CheeseCountChanged;
        public static event Action MouseFlagsNeedRefresh;
        public static event Action NGPlusActivated;
        public static event Action BlackCatEntered;
        public static event Action E05GrainSoakGot;
        public static event Action DialogueStarted;
        public static event Action DialogueEnded;
        public static event Action NotebookOpened;
        public static event Action NotebookClosed;

        public static bool DialogueActive { get; set; }
        public static bool NotebookOpen { get; set; }
        public static bool InputLocked
        {
            get { return DialogueActive || NotebookOpen; }
        }

        public static void RaiseVariableChanged(string name)
        {
            if (VariableChanged != null)
                VariableChanged(name);
        }

        public static void RaiseCheeseCountChanged()
        {
            if (CheeseCountChanged != null)
                CheeseCountChanged();
        }

        public static void RaiseMouseFlagsNeedRefresh()
        {
            if (MouseFlagsNeedRefresh != null)
                MouseFlagsNeedRefresh();
        }

        public static void RaiseNGPlusActivated()
        {
            if (NGPlusActivated != null)
                NGPlusActivated();
        }

        public static void RaiseBlackCatEntered()
        {
            if (BlackCatEntered != null)
                BlackCatEntered();
        }

        public static void RaiseE05GrainSoakGot()
        {
            if (E05GrainSoakGot != null)
                E05GrainSoakGot();
        }

        public static void RaiseDialogueStarted()
        {
            DialogueActive = true;
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            if (DialogueStarted != null)
                DialogueStarted();
        }

        public static void RaiseDialogueEnded()
        {
            DialogueActive = false;
            if (!NotebookOpen)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
            if (DialogueEnded != null)
                DialogueEnded();
        }

        public static void RaiseNotebookOpened()
        {
            NotebookOpen = true;
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            if (NotebookOpened != null)
                NotebookOpened();
        }

        public static void RaiseNotebookClosed()
        {
            NotebookOpen = false;
            if (!DialogueActive)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
            if (NotebookClosed != null)
                NotebookClosed();
        }
    }
}
