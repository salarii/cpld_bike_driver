#include <QVBoxLayout>
#include <QTabWidget>
#include "widget.h"
#include "communication.h"
#include "data_types.h"

unsigned int const MainClockFreq = 1000000;

using namespace QtCharts;

const QStringList flashParamsMess ={
    "Plynomial parameter 0: ",
    "Plynomial parameter 1: ",
    "Plynomial parameter 2: ",
    "Plynomial parameter 3: "
};

QString const labelText = "Current Voltage: ";

Widget::Widget(QWidget *parent)
    : QWidget(parent)
{
    sendBuff = new unsigned char(10);

    QVBoxLayout *layout = new QVBoxLayout;
    QTabWidget * functionsTabs = new QTabWidget;

    QWidget * triggerWidget = new QWidget;
    QHBoxLayout *interfaceLayout = new QHBoxLayout;
    triggerWidget->setLayout(interfaceLayout);



    this->setLayout(layout);

    chartView = new  QChartView(this);

    series = new QLineSeries();
    label = new QLabel("");

    chartView->setChart(createChart());
    layout->addWidget(functionsTabs);

    layout->addWidget(label);


    this->setMinimumSize(900, 900);
    this->adjustSize();

    auto title = new QLabel("Generate wave: ");

    frequency = new QSpinBox();
    frequency->setRange(20, 100000);
    frequency->setSingleStep(10);
    frequency->setValue(1000);
    auto hz = new QLabel(" Hz ");
    pulseWidth = new QSpinBox();

    pulseWidth->setRange(1, 100);
    pulseWidth->setSingleStep(10);
    pulseWidth->setValue(100);
    auto percent = new QLabel(" % ");

    startButton = new QPushButton( "Start" );
    interfaceLayout->addWidget(title);
    interfaceLayout->addWidget(frequency);
    interfaceLayout->addWidget(hz);
    interfaceLayout->addWidget(pulseWidth);
    interfaceLayout->addWidget(percent);
    interfaceLayout->addWidget(startButton);
    startButton->setCheckable(true);


    QWidget * flashWidget = new QWidget;
    QVBoxLayout *flashLayout = new QVBoxLayout;
    flashWidget->setLayout(flashLayout);
    auto titleFlash = new QLabel("Manage flash: ");
    flashLayout->addWidget(titleFlash);

    valInput = new QLineEdit();
    valInput->setInputMask("HHHHHH;");

    parameterList = new QComboBox();
    QStringList params = { "poly_par 0", "poly_par 1", "poly_par 2" , "poly_par 3"};
    parameterList->addItems(params);
    QPushButton * saveFlash= new QPushButton("save to flash");

    QObject::connect(saveFlash, &QPushButton::clicked,
                     this, &Widget::sendDataToFlash);

    parLabels[0] = new QLabel(flashParamsMess[0]);
    parLabels[1] = new QLabel(flashParamsMess[1]);
    parLabels[2] = new QLabel(flashParamsMess[2]);
    parLabels[3] = new QLabel(flashParamsMess[3]);
    QPushButton * loadFlash= new QPushButton("load from flash");
    flashLayout->addWidget(parameterList);
    flashLayout->addWidget(valInput);
    flashLayout->addWidget(saveFlash);
    flashLayout->addWidget(parLabels[0]);
    flashLayout->addWidget(parLabels[1]);
    flashLayout->addWidget(parLabels[2]);
    flashLayout->addWidget(parLabels[3]);
    flashLayout->addWidget(loadFlash);

    QWidget * blcdWidget = new QWidget;
    QVBoxLayout *blcdLayout = new QVBoxLayout;
    blcdWidget->setLayout(blcdLayout);
    auto titleBlcd = new QLabel("Manage BLCD motor: ");
    blcdLayout->addWidget(titleBlcd);

    sliderSpeed = new QSlider();
    sliderSpeed->setRange(1, 100);
    blcdLayout->addWidget(sliderSpeed);
    sliderSpeed->setOrientation(Qt::Horizontal);

    sliderForce = new QSlider();
    sliderSpeed->setRange(1, 100);
    blcdLayout->addWidget(sliderForce);
    sliderForce->setOrientation(Qt::Horizontal);

    QWidget * triggAndChartWidget = new QWidget;
    QVBoxLayout *layoutTCW = new QVBoxLayout;
    triggAndChartWidget->setLayout(layoutTCW);
    layoutTCW->addWidget(triggerWidget);
    layoutTCW->addWidget(chartView);

    QObject::connect(startButton, &QPushButton::clicked,
                     this, &Widget::startMeasurement);

    functionsTabs->addTab(triggAndChartWidget, "Waveform");
    functionsTabs->addTab(flashWidget, "Flash");
    functionsTabs->addTab(blcdWidget, "Motor");
    triggerWidget->setMaximumHeight(80);
}

void
Widget::serialProblem()
{
    QMessageBox msgBox;
    msgBox.setText("Missing serial port communication.\n Setup some kind of \n"
                   "serial port <--> your hardware (cpld/fpga) communication.\n"
                   "for example use CP2102 chips based hardware as a bridge");
    msgBox.setIcon(QMessageBox::Critical );

    msgBox.addButton("Ok", QMessageBox::AcceptRole);
    msgBox.exec();
}

void
Widget::displayFlash(FlashData const * _value)
{
     auto idx = _value->address /3;
     unsigned int value = (unsigned int)_value->data[0] +
    (((unsigned int)_value->data[1])<<8) +
    (((unsigned int)_value->data[1])<<16);
    QString  valText = QString().arg(value, 6, 16);
    parLabels[idx]->setText( flashParamsMess[idx] + valText);
}

void
Widget::requestDataFromFlash()
{
    for (int i = 0;i<4;i++)
    {
        sendBuff[0] = (unsigned  char)CommandCodes::GetFlash;
        sendBuff[1] = i*3;
        emit sendToHardware(sendBuff, 2);
    }
}

void
Widget::sendDataToFlash()
{
    QString valueText = valInput->text();

    bool bStatus = false;
    unsigned int val = valueText.toUInt(&bStatus,16);

    unsigned  char index = parameterList->currentIndex();

     sendBuff[0] = (unsigned  char)CommandCodes::LoadFlash;
     sendBuff[1] = index*3;
     sendBuff[2] = val & 0xff;
     sendBuff[3] = (val  >> 8) & 0xff;
     sendBuff[4] = val  >> 16;

     emit sendToHardware(sendBuff, 5);

}

void
Widget::startMeasurement(bool _checked)
{

    if ( _checked == false )
    {
        startButton->setText("Start");

        sendBuff[0] = (unsigned  char)CommandCodes::StopOpCodeTermistor;

        emit sendToHardware(sendBuff, 1);

    }
    else
    {
        startButton->setText("Stop");
        short unsigned freq;
        short unsigned pulse;

        freq = MainClockFreq/frequency->value();
        pulse = (pulseWidth->value()* freq)/100;

        sendBuff[0] = (unsigned  char)CommandCodes::TriggerOpCodeTermistor;
        sendBuff[1] = freq >> 8;
        sendBuff[2] = freq  & 0xff;
        sendBuff[3] = pulse  >> 8;
        sendBuff[4] = pulse & 0xff;

        emit sendToHardware(sendBuff, 5);
    }
}


QChart * Widget::createChart()
{
    QLineSeries * tmp = new QLineSeries();
    auto list = series->points();
    if ( list.size() > 100 )
    {
        list.removeFirst();
    }

    tmp->append(list);
    series = tmp;
    QChart * newChart = new QChart;
    series->setName("temperature");
    newChart->setTitle("Termistor data:");
    newChart->addSeries(series);

    QValueAxis *axisX = new QValueAxis;

    newChart->addAxis(axisX, Qt::AlignBottom);

    QValueAxis *axisY = new QValueAxis;

    newChart->addAxis(axisY, Qt::AlignLeft);
    series->attachAxis(axisX);
    series->attachAxis(axisY);
    axisX->applyNiceNumbers();
    axisY->setRange(25.0, 130.0);
    axisY->applyNiceNumbers();
    return newChart;
}


void Widget::serviceMeasurement(Measurement const * _measurement)
{
    float time = ((float)_measurement->time)/10.0;
    if ( series->points().size() > 0 &&  series->points().back().x() > time )
    {
        series->clear();
    }
    series->append(time,_measurement->temperature);

    auto message = labelText + QString().setNum(_measurement->voltage, 'g', 4) + QString(" V ");
    message += QString(" Temperature:") + QString().setNum(_measurement->temperature) + QString(" Celsius");

    label->setText(message);
    QChart* chartToDelete=NULL;
    if(chartView->chart())
    {
        chartToDelete=chartView->chart();
    }
    chartView->setChart(createChart());

    delete chartToDelete;

}

Widget::~Widget()
{
}

