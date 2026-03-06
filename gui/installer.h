#pragma once

#include <QDialog>
#include <QProcess>
#include <QListWidget>
#include <QPushButton>
#include <QTextEdit>

class InstallerDialog : public QDialog {
    Q_OBJECT
public:
    explicit InstallerDialog(QWidget *parent = nullptr);

private slots:
    void refreshDevices();
    void startInstall();
    void onProcessOutput();
    void onProcessFinished(int exitCode, QProcess::ExitStatus status);

private:
    QListWidget *deviceList;
    QPushButton *refreshBtn;
    QPushButton *installBtn;
    QTextEdit *logView;
    QProcess *proc;
};