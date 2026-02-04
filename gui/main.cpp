#include <QApplication>
#include <QMainWindow>
#include <QWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QLabel>
#include <QPainter>
#include <QGraphicsDropShadowEffect>
#include <QTimer>
#include <QDateTime>
#include <QMenu>
#include <QMenuBar>
#include <QStatusBar>
#include <QSystemTrayIcon>
#include <QMessageBox>
#include <QFileDialog>
#include <QInputDialog>
#include <QFontDatabase>
#include <QSplitter>
#include <QTreeView>
#include <QListView>
#include <QTableView>
#include <QTextEdit>
#include <QTabWidget>
#include <QToolBar>
#include <QDockWidget>
#include <QProgressBar>
#include <QSlider>
#include <QDial>
#include <QLCDNumber>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QComboBox>
#include <QFontComboBox>
#include <QLineEdit>
#include <QTextEdit>
#include <QPlainTextEdit>
#include <QScrollBar>
#include <QHeaderView>
#include <QKeySequenceEdit>
#include <QCalendarWidget>
#include <QDateTimeEdit>
#include <QTimeEdit>
#include <QDateEdit>

class LampDesktop : public QMainWindow {
    Q_OBJECT
public:
    LampDesktop(QWidget *parent = nullptr) : QMainWindow(parent) {
        // إعداد النافذة الرئيسية
        setWindowTitle("🪔 Lamp OS Desktop");
        setGeometry(100, 100, 1024, 768);
        
        // تأثيرات الشفافية والزجاج
        setAttribute(Qt::WA_TranslucentBackground);
        setWindowFlags(Qt::FramelessWindowHint);
        
        setupUI();
        setupSystemTray();
        setupAnimations();
    }
    
protected:
    void paintEvent(QPaintEvent *event) override {
        QPainter painter(this);
        painter.setRenderHint(QPainter::Antialiasing);
        
        // خلفية متدرجة مع تأثيرات ضوئية
        QLinearGradient gradient(0, 0, width(), height());
        gradient.setColorAt(0, QColor(30, 60, 114));
        gradient.setColorAt(0.5, QColor(45, 95, 155));
        gradient.setColorAt(1, QColor(60, 130, 200));
        
        painter.fillRect(rect(), gradient);
        
        // تأثيرات ضوئية
        painter.setPen(QPen(QColor(255, 255, 255, 30), 2));
        painter.drawRect(rect().adjusted(5, 5, -5, -5));
    }
    
private slots:
    void showStartMenu() {
        startMenu->popup(mapToGlobal(QPoint(10, height() - startButton->height() - 10)));
    }
    
    void shutdown() {
        if (QMessageBox::question(this, "Shutdown", "Are you sure you want to shutdown Lamp OS?",
                                 QMessageBox::Yes | QMessageBox::No) == QMessageBox::Yes) {
            qApp->quit();
        }
    }
    
    void updateDateTime() {
        timeLabel->setText(QDateTime::currentDateTime().toString("hh:mm AP"));
        dateLabel->setText(QDateTime::currentDateTime().toString("dddd, MMMM d"));
    }
    
private:
    void setupUI() {
        // إنشاء ويدجت مركزية
        QWidget *centralWidget = new QWidget(this);
        centralWidget->setObjectName("centralWidget");
        
        // تأثير الظل للواجهة المركزية
        QGraphicsDropShadowEffect *shadow = new QGraphicsDropShadowEffect();
        shadow->setBlurRadius(40);
        shadow->setColor(QColor(0, 0, 0, 100));
        shadow->setOffset(0, 5);
        centralWidget->setGraphicsEffect(shadow);
        
        // تصميم الواجهة الرئيسية
        QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
        
        // شريط العنوان المخصص
        QWidget *titleBar = createTitleBar();
        mainLayout->addWidget(titleBar);
        
        // منطقة المحتوى الرئيسية
        QSplitter *mainSplitter = new QSplitter(Qt::Horizontal);
        
        // الجانب الأيسر: قائمة التطبيقات
        QWidget *appPanel = createAppPanel();
        mainSplitter->addWidget(appPanel);
        
        // المنطقة الوسطى: سطح المكتب
        QWidget *desktopArea = createDesktopArea();
        mainSplitter->addWidget(desktopArea);
        
        // الجانب الأيمن: معلومات النظام
        QWidget *systemPanel = createSystemPanel();
        mainSplitter->addWidget(systemPanel);
        
        mainSplitter->setStretchFactor(0, 1);
        mainSplitter->setStretchFactor(1, 3);
        mainSplitter->setStretchFactor(2, 1);
        
        mainLayout->addWidget(mainSplitter, 1);
        
        // شريط المهام (Taskbar)
        QWidget *taskbar = createTaskbar();
        mainLayout->addWidget(taskbar);
        
        setCentralWidget(centralWidget);
        
        // تطبيق الأنماط
        applyStyles();
    }
    
    QWidget* createTitleBar() {
        QWidget *titleBar = new QWidget();
        titleBar->setFixedHeight(40);
        titleBar->setStyleSheet(
            "background: rgba(20, 25, 40, 0.9);"
            "border-top-left-radius: 10px;"
            "border-top-right-radius: 10px;"
            "border-bottom: 1px solid rgba(255, 255, 255, 0.1);"
        );
        
        QHBoxLayout *layout = new QHBoxLayout(titleBar);
        layout->setContentsMargins(10, 0, 10, 0);
        
        QLabel *logo = new QLabel("🪔 Lamp OS");
        logo->setStyleSheet("color: white; font-size: 18px; font-weight: bold;");
        
        QPushButton *closeBtn = new QPushButton("✕");
        closeBtn->setFixedSize(30, 30);
        closeBtn->setStyleSheet(
            "QPushButton {"
            "   background: #ff5c57;"
            "   border-radius: 15px;"
            "   color: white;"
            "   font-weight: bold;"
            "}"
            "QPushButton:hover { background: #ff6b66; }"
        );
        connect(closeBtn, &QPushButton::clicked, this, &LampDesktop::shutdown);
        
        layout->addWidget(logo);
        layout->addStretch();
        layout->addWidget(closeBtn);
        
        return titleBar;
    }
    
    QWidget* createAppPanel() {
        QWidget *panel = new QWidget();
        panel->setStyleSheet(
            "background: rgba(25, 30, 50, 0.8);"
            "border-right: 1px solid rgba(255, 255, 255, 0.05);"
        );
        
        QVBoxLayout *layout = new QVBoxLayout(panel);
        layout->setContentsMargins(5, 10, 5, 10);
        
        QLabel *title = new QLabel("Applications");
        title->setStyleSheet("color: #5dade2; font-size: 14px; font-weight: bold; margin-bottom: 10px;");
        
        QStringList apps = {"File Manager", "Web Browser", "Text Editor", 
                           "Terminal", "Settings", "Media Player", "Calculator"};
        
        for (const QString &app : apps) {
            QPushButton *appBtn = new QPushButton("📁 " + app);
            appBtn->setStyleSheet(
                "QPushButton {"
                "   text-align: left;"
                "   padding: 8px 15px;"
                "   background: transparent;"
                "   color: #d6dbdf;"
                "   border-radius: 5px;"
                "}"
                "QPushButton:hover {"
                "   background: rgba(52, 152, 219, 0.3);"
                "}"
            );
            layout->addWidget(appBtn);
        }
        
        layout->addStretch();
        return panel;
    }
    
    QWidget* createDesktopArea() {
        QWidget *desktop = new QWidget();
        desktop->setStyleSheet("background: transparent;");
        
        QVBoxLayout *layout = new QVBoxLayout(desktop);
        layout->setContentsMargins(20, 20, 20, 20);
        
        QGridLayout *grid = new QGridLayout();
        
        QStringList desktopIcons = {
            "Computer", "Documents", "Pictures", "Music",
            "Videos", "Downloads", "Network", "Trash"
        };
        
        QStringList iconEmojis = {
            "💻", "📄", "🖼️", "🎵",
            "🎬", "📥", "🌐", "🗑️"
        };
        
        for (int i = 0; i < desktopIcons.size(); i++) {
            QPushButton *icon = new QPushButton(iconEmojis[i] + "\n" + desktopIcons[i]);
            icon->setStyleSheet(
                "QPushButton {"
                "   background: rgba(255, 255, 255, 0.1);"
                "   border-radius: 10px;"
                "   color: white;"
                "   padding: 10px;"
                "   font-size: 12px;"
                "}"
                "QPushButton:hover {"
                "   background: rgba(255, 255, 255, 0.2);"
                "   border: 1px solid rgba(255, 255, 255, 0.3);"
                "}"
            );
            icon->setFixedSize(100, 80);
            grid->addWidget(icon, i / 4, i % 4);
        }
        
        layout->addLayout(grid);
        layout->addStretch();
        
        return desktop;
    }
    
    QWidget* createSystemPanel() {
        QWidget *panel = new QWidget();
        panel->setStyleSheet(
            "background: rgba(25, 30, 50, 0.8);"
            "border-left: 1px solid rgba(255, 255, 255, 0.05);"
        );
        
        QVBoxLayout *layout = new QVBoxLayout(panel);
        layout->setContentsMargins(10, 10, 10, 10);
        
        QLabel *title = new QLabel("System Info");
        title->setStyleSheet("color: #5dade2; font-size: 14px; font-weight: bold; margin-bottom: 15px;");
        
        QLabel *cpuLabel = new QLabel("💻 CPU: 4 Cores");
        QLabel *ramLabel = new QLabel("🧠 RAM: 8 GB");
        QLabel *diskLabel = new QLabel("💾 Disk: 128 GB");
        QLabel *networkLabel = new QLabel("📶 Network: Connected");
        
        QString labelStyle = "color: #d6dbdf; font-size: 12px; margin: 5px 0;";
        cpuLabel->setStyleSheet(labelStyle);
        ramLabel->setStyleSheet(labelStyle);
        diskLabel->setStyleSheet(labelStyle);
        networkLabel->setStyleSheet(labelStyle);
        
        QProgressBar *cpuBar = new QProgressBar();
        cpuBar->setValue(45);
        cpuBar->setStyleSheet(
            "QProgressBar {"
            "   border: 1px solid rgba(255, 255, 255, 0.1);"
            "   border-radius: 3px;"
            "   text-align: center;"
            "   color: white;"
            "}"
            "QProgressBar::chunk {"
            "   background: qlineargradient(x1:0, y1:0, x2:1, y2:0,"
            "               stop:0 #3498db, stop:1 #2980b9);"
            "   border-radius: 3px;"
            "}"
        );
        
        layout->addWidget(title);
        layout->addWidget(cpuLabel);
        layout->addWidget(cpuBar);
        layout->addWidget(ramLabel);
        layout->addWidget(diskLabel);
        layout->addWidget(networkLabel);
        layout->addStretch();
        
        return panel;
    }
    
    QWidget* createTaskbar() {
        QWidget *taskbar = new QWidget();
        taskbar->setFixedHeight(50);
        taskbar->setStyleSheet(
            "background: rgba(20, 25, 40, 0.95);"
            "border-top: 1px solid rgba(255, 255, 255, 0.1);"
            "border-bottom-left-radius: 10px;"
            "border-bottom-right-radius: 10px;"
        );
        
        QHBoxLayout *layout = new QHBoxLayout(taskbar);
        layout->setContentsMargins(10, 5, 10, 5);
        
        startButton = new QPushButton("🪔 Start");
        startButton->setFixedSize(100, 40);
        startButton->setStyleSheet(
            "QPushButton {"
            "   background: qlineargradient(x1:0, y1:0, x2:1, y2:0,"
            "               stop:0 #3498db, stop:1 #2980b9);"
            "   color: white;"
            "   border-radius: 20px;"
            "   font-weight: bold;"
            "}"
            "QPushButton:hover {"
            "   background: qlineargradient(x1:0, y1:0, x2:1, y2:0,"
            "               stop:0 #5dade2, stop:1 #3498db);"
            "}"
        );
        connect(startButton, &QPushButton::clicked, this, &LampDesktop::showStartMenu);
        
        startMenu = new QMenu(this);
        startMenu->setStyleSheet(
            "QMenu {"
            "   background: rgba(30, 35, 60, 0.95);"
            "   border: 1px solid rgba(255, 255, 255, 0.1);"
            "   border-radius: 10px;"
            "   padding: 10px;"
            "}"
            "QMenu::item {"
            "   padding: 8px 25px 8px 20px;"
            "   border-radius: 5px;"
            "   color: white;"
            "}"
            "QMenu::item:selected {"
            "   background: rgba(52, 152, 219, 0.5);"
            "}"
        );
        
        startMenu->addAction("📁 File Manager");
        startMenu->addAction("🌐 Web Browser");
        startMenu->addAction("📝 Text Editor");
        startMenu->addSeparator();
        startMenu->addAction("⚙️ Settings");
        startMenu->addAction("📦 Software Center");
        startMenu->addSeparator();
        startMenu->addAction("⏻ Shutdown")->connect(startMenu->actions().last(), &QAction::triggered,
                                                    this, &LampDesktop::shutdown);
        
        timeLabel = new QLabel();
        dateLabel = new QLabel();
        timeLabel->setStyleSheet("color: white; font-size: 18px; font-weight: bold;");
        dateLabel->setStyleSheet("color: rgba(255, 255, 255, 0.7); font-size: 11px;");
        
        updateDateTime();
        QTimer *timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &LampDesktop::updateDateTime);
        timer->start(1000);
        
        layout->addWidget(startButton);
        layout->addStretch();
        layout->addWidget(timeLabel);
        layout->addWidget(dateLabel);
        
        return taskbar;
    }
    
    void setupSystemTray() {
        QSystemTrayIcon *trayIcon = new QSystemTrayIcon(QIcon(":/icons/tray.png"), this);
        QMenu *trayMenu = new QMenu(this);
        trayMenu->addAction("Show Desktop", this, &LampDesktop::showNormal);
        trayMenu->addAction("Settings", this, [](){ QMessageBox::information(nullptr, "Settings", "Settings will open here"); });
        trayMenu->addSeparator();
        trayMenu->addAction("Exit", qApp, &QApplication::quit);
        trayIcon->setContextMenu(trayMenu);
        trayIcon->show();
    }
    
    void setupAnimations() {
        QGraphicsOpacityEffect *opacityEffect = new QGraphicsOpacityEffect(this);
        opacityEffect->setOpacity(0.95);
        setGraphicsEffect(opacityEffect);
    }
    
    void applyStyles() {
        setStyleSheet(R"(
            QMainWindow {
                background: transparent;
            }
            #centralWidget {
                background: rgba(30, 35, 60, 0.7);
                border-radius: 10px;
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            QScrollBar:vertical {
                border: none;
                background: rgba(255, 255, 255, 0.1);
                width: 10px;
                border-radius: 5px;
                margin: 0px;
            }
            QScrollBar::handle:vertical {
                background: rgba(52, 152, 219, 0.7);
                border-radius: 5px;
                min-height: 20px;
            }
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
                border: none;
                background: none;
                height: 0px;
            }
        )");
    }
    
private:
    QPushButton *startButton;
    QMenu *startMenu;
    QLabel *timeLabel;
    QLabel *dateLabel;
};

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    app.setApplicationName("Lamp OS Desktop");
    app.setApplicationDisplayName("Lamp OS");
    app.setWindowIcon(QIcon(":/icons/lamp.ico"));
    
    QFontDatabase::addApplicationFont(":/fonts/roboto.ttf");
    app.setFont(QFont("Roboto", 10));
    
    LampDesktop desktop;
    desktop.show();
    
    return app.exec();
}

#include "main.moc"
