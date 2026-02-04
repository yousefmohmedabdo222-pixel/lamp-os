#include "installer.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QProcess>

InstallerDialog::InstallerDialog(QWidget *parent) : QDialog(parent) {
    setWindowTitle("🪔 Lamp OS Installer");
    setMinimumSize(600, 400);

    deviceList = new QListWidget(this);
    refreshBtn = new QPushButton("Refresh", this);
    installBtn = new QPushButton("Install to selected disk...", this);
    installBtn->setStyleSheet("background: #3498db; color: white; padding: 8px; border-radius: 6px;");
    logView = new QTextEdit(this);
    logView->setReadOnly(true);

    QHBoxLayout *topRow = new QHBoxLayout();
    topRow->addWidget(new QLabel("Available disks:"));
    topRow->addStretch();
    topRow->addWidget(refreshBtn);

    QVBoxLayout *main = new QVBoxLayout(this);
    main->addLayout(topRow);
    main->addWidget(deviceList, 1);
    main->addWidget(installBtn);
    main->addWidget(new QLabel("Installer Output:"));
    main->addWidget(logView, 1);

    connect(refreshBtn, &QPushButton::clicked, this, &InstallerDialog::refreshDevices);
    connect(installBtn, &QPushButton::clicked, this, &InstallerDialog::startInstall);

    proc = new QProcess(this);
    connect(proc, &QProcess::readyReadStandardOutput, this, &InstallerDialog::onProcessOutput);
    connect(proc, &QProcess::readyReadStandardError, this, &InstallerDialog::onProcessOutput);
    connect(proc, QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished), this, &InstallerDialog::onProcessFinished);

    refreshDevices();
}

void InstallerDialog::refreshDevices() {
    deviceList->clear();
    // Use lsblk to list physical disks
    QProcess lsblk;
    lsblk.start("lsblk -dn -o NAME,SIZE,TYPE | grep disk", QIODevice::ReadOnly);
    lsblk.waitForFinished(1000);
    QString out = lsblk.readAllStandardOutput();
    for (const QString &line : out.split('\n', Qt::SkipEmptyParts)) {
        deviceList->addItem(line.trimmed());
    }
}

void InstallerDialog::startInstall() {
    if (deviceList->selectedItems().isEmpty()) {
        QMessageBox::warning(this, "Select Disk", "Please select a target disk to install to.");
        return;
    }
    QString item = deviceList->selectedItems().first()->text();
    QString dev = item.split(' ', Qt::SkipEmptyParts).first();
    QString path = "/dev/" + dev;

    if (QMessageBox::question(this, "Confirm Installation",
                              QString("All data on %1 will be lost. Continue?").arg(path)) != QMessageBox::Yes)
        return;

    // Use pkexec to ask for privileges and run the installer script. If not available, try sudo.
    QString program;
    QStringList args;
    if (QFile::exists("/usr/bin/pkexec") || QFile::exists("/bin/pkexec") ) {
        program = "pkexec";
        args << "/workspaces/lamp-os/scripts/install-to-disk.sh" << path;
    } else if (QFile::exists("/usr/bin/sudo") || QFile::exists("/bin/sudo")) {
        program = "sudo";
        args << "/workspaces/lamp-os/scripts/install-to-disk.sh" << path;
    } else {
        QMessageBox::critical(this, "Privilege Escalation Not Found", "Neither pkexec nor sudo is available. Cannot start installer.");
        return;
    }

    logView->append("Starting installer: " + program + " " + args.join(' '));
    installBtn->setEnabled(false);
    proc->start(program, args);
}

void InstallerDialog::onProcessOutput() {
    QString out = proc->readAllStandardOutput();
    QString err = proc->readAllStandardError();
    if (!out.isEmpty()) logView->append(out);
    if (!err.isEmpty()) logView->append(err);
}

void InstallerDialog::onProcessFinished(int exitCode, QProcess::ExitStatus status) {
    logView->append(QString("Installer finished with code %1").arg(exitCode));
    installBtn->setEnabled(true);
}
