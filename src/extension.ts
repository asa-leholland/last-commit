import * as vscode from "vscode";
import Timer from "./Timer";

const lastcommitconfig = vscode.workspace.getConfiguration("lastcommit");

export function activate(context: vscode.ExtensionContext) {

  const timer = new Timer();
  timer.startTimer();

  let stopTimer = vscode.commands.registerCommand("lastcommit.stopTimer", () => {
    timer.stopTimer();
  });

  let resetTimer = vscode.commands.registerCommand(
    "lastcommit.resetTimer",
    () => {
      vscode.window
        .showQuickPick(["Yes", "No"], {
          placeHolder: "Do you really want to reset the TimeSince timer?",
          canPickMany: false,
        })
        .then((pick) => {
          if (pick === "Yes") {
            timer.resetTimer();
            vscode.window.showInformationMessage(
              "TimeSince timer has been reset!"
            );
          }
        });
    }
  );

  context.subscriptions.push(resetTimer);
}

export function deactivate() { }
