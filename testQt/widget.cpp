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
    : QWidget(parent),motorRun(false)
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
    motorSeries = new QLineSeries();
    label = new QLabel("");

    chartView->setChart(createChart());
    layout->addWidget(functionsTabs);

    layout->addWidget(label);


    this->setMinimumSize(900, 900);
    this->adjustSize();

    auto title = new QLabel("Max temperature: ");

    adcChannelList = new QComboBox();
    QStringList channels = { "adc channel 0", "adc channel 1", "adc channel 2" , "adc channel 3"};
    adcChannelList->addItems(channels);

    celsius = new QSpinBox();
    celsius->setRange(30, 120);
    celsius->setSingleStep(1);
    celsius->setValue(40);
    auto unit = new QLabel(" °C ");

;
    interfaceLayout->addWidget(title);
    interfaceLayout->addWidget(celsius);
    interfaceLayout->addWidget(unit);

    interfaceLayout->addWidget(adcChannelList);

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
    QObject::connect(loadFlash, &QPushButton::clicked,
                     this, &Widget::requestDataFromFlash);

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
    auto titleBlcd = new QLabel("Manage BLCD motor");
    blcdLayout->addWidget(titleBlcd);

    labelSpeed = new QLabel("Set speed: 0");
    blcdLayout->addWidget(labelSpeed);

    sliderSpeed = new QSlider();
    sliderSpeed->setRange(0, 255);
    blcdLayout->addWidget(sliderSpeed);
    sliderSpeed->setOrientation(Qt::Horizontal);

    connect(sliderSpeed, &QSlider::valueChanged, this, &Widget::motorSliderChanged);

    labelForce = new QLabel("Pulse width: 0 %");
    blcdLayout->addWidget(labelForce);

    sliderForce = new QSlider();
    sliderForce->setRange(1, 100);
    blcdLayout->addWidget(sliderForce);
    sliderForce->setOrientation(Qt::Horizontal);

    connect(sliderForce, &QSlider::valueChanged, this, &Widget::motorSliderChanged);

    runMotorButton =  new QPushButton("Run motor");
    runMotorButton->setCheckable(true);

    QCheckBox * hal = new QCheckBox;
    QLabel * halLabel = new QLabel("Use hal: ");
    QHBoxLayout * botLayout = new QHBoxLayout;

    botLayout->addWidget(halLabel);
    botLayout->addWidget(hal);
    botLayout->addWidget(runMotorButton);

    blcdLayout->addLayout(botLayout);

    QObject::connect(runMotorButton, &QPushButton::clicked,
                     this, &Widget::startMotor);

    motorChartView  = new  QChartView(this);
    motorChartView->setChart(createMotorChart());
    blcdLayout->addWidget(motorChartView);

    QWidget * triggAndChartWidget = new QWidget;
    QVBoxLayout *layoutTCW = new QVBoxLayout;
    triggAndChartWidget->setLayout(layoutTCW);
    layoutTCW->addWidget(triggerWidget);
    layoutTCW->addWidget(chartView);

    //QObject::connect(startButton, &QPushButton::clicked,
    //                 this, &Widget::startMeasurement);

    functionsTabs->addTab(triggAndChartWidget, "Waveform");
    functionsTabs->addTab(flashWidget, "Flash");
    functionsTabs->addTab(blcdWidget, "Motor");
    triggerWidget->setMaximumHeight(80);

    QObject::connect(adcChannelList,QOverload<int>::of(&QComboBox::activated),
                     this,&Widget::setMeasurementChannel);
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

int  shift = 30;

void
Widget::displayFlash(FlashData const * _value)
{
     auto idx = _value->address /3;
    idx-=shift;
     unsigned int value = (unsigned int)_value->data[2] +
    (((unsigned int)_value->data[1])<<8) +
    (((unsigned int)_value->data[0])<<16);
    QString  valText = QString().number(value, 16);
    parLabels[idx]->setText( flashParamsMess[idx] + valText);
}

void
Widget::requestDataFromFlash()
{
    unsigned  char index = parameterList->currentIndex();
    index+=shift;
    sendBuff[0] = (unsigned  char)CommandCodes::ReadFlashOpCode;
    sendBuff[1] = index*3;
    emit sendToHardware(sendBuff, 2);

}


void
Widget::setMeasurementChannel(int _index)
{

    sendBuff[0] = (unsigned  char)CommandCodes::ChangeADCChannel;
    sendBuff[1] = _index;
    emit sendToHardware(sendBuff, 2);

}


void
Widget::sendDataToFlash()
{
    QString valueText = valInput->text();

    bool bStatus = false;
    unsigned int val = valueText.toUInt(&bStatus,16);

    unsigned  char index = parameterList->currentIndex();
    index+=shift;
     sendBuff[0] = (unsigned  char)CommandCodes::WriteFlashOpCode;
     sendBuff[1] = index*3;
     sendBuff[2] = val  >> 16;
     sendBuff[3] = (val  >> 8) & 0xff;
     sendBuff[4] = val & 0xff;
    unsigned  char  triada = sendBuff[2];
    triada = sendBuff[3];
    triada = sendBuff[4];
     emit sendToHardware(sendBuff, 5);

}

void
Widget::motorSliderChanged()
{

        char unsigned speed = sliderSpeed->value();
        char unsigned pulse = sliderForce->value();
        labelSpeed->setText( QString("Set speed: ") + QString().number(speed, 10));

        labelForce->setText( QString("Pulse width: ")+ QString().number(pulse, 10) +QString(" %"));
        if (motorRun == true)
        {
            sendBuff[0] = (unsigned  char)CommandCodes::StartMotorOpCode;
            sendBuff[1] = speed;
            sendBuff[2] = (unsigned  char)255.0*((float)pulse/100.0);
            sendBuff[3] = celsius->value();
            emit sendToHardware(sendBuff, 4);
        }
}

void
Widget::startMotor(bool _checked)
{
    delete motorSeries;
    motorSeries = new QLineSeries();

    if ( _checked == false )
    {
        runMotorButton->setText("Run motor");

        sendBuff[0] = (unsigned  char)CommandCodes::StopOpCode;

        emit sendToHardware(sendBuff, 1);
        motorRun = false;

    }
    else
    {
        series->clear();
        motorRun = true;
        motorTriggerTime = lastTime;
        runMotorButton->setText("Stop");
        motorSliderChanged();
    }
}


void
Widget::startMeasurement(bool _checked)
{
/*
    if ( _checked == false )
    {
        startButton->setText("Start");

        sendBuff[0] = (unsigned  char)CommandCodes::StopOpCode;

        emit sendToHardware(sendBuff, 1);

    }
    else
    {
        startButton->setText("Stop");
        short unsigned freq;
        short unsigned pulse;

        freq = MainClockFreq/frequency->value();
        pulse = (pulseWidth->value()* freq)/100;

        //sendBuff[0] = (unsigned  char)CommandCodes::TriggerTermistorOpCode;
        sendBuff[1] = freq >> 8;
        sendBuff[2] = freq  & 0xff;
        sendBuff[3] = pulse  >> 8;
        sendBuff[4] = pulse & 0xff;

        emit sendToHardware(sendBuff, 5);
    }
*/
}

QChart * Widget::createMotorChart()
{
    QLineSeries * tmp = new QLineSeries();
    auto list = motorSeries->points();
    if ( list.size() > 100 )
    {
        list.removeFirst();
    }

    tmp->append(list);

    delete motorSeries;
    motorSeries = tmp;
    QChart * newChart = new QChart;
    motorSeries->setName("motor speed (rpm)");
    newChart->setTitle("Motor Data:");
    newChart->addSeries(motorSeries);

    QValueAxis *axisX = new QValueAxis;

    newChart->addAxis(axisX, Qt::AlignBottom);

    QValueAxis *axisY = new QValueAxis;

    newChart->addAxis(axisY, Qt::AlignLeft);
    motorSeries->attachAxis(axisX);
    motorSeries->attachAxis(axisY);
    axisX->applyNiceNumbers();
    axisY->setRange(0.0, 300.0);
    axisY->applyNiceNumbers();
    return newChart;
}


QChart * Widget::createChart()
{
    QLineSeries * tmp = new QLineSeries();
    auto list = series->points();
    if ( list.size() > 100 && !motorRun  )
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
    axisY->setRange(25.0, 80.0);
    axisY->applyNiceNumbers();
    return newChart;
}


void Widget::serviceMeasurement(Measurement const * _measurement)
{
    float time = ((float)_measurement->time)/1000.0;
    if ( series->points().size() == 0 )
    {
        tempTime = time;
    }
    if ( series->points().size() > 0 &&  series->points().back().x() > time )
    {
        tempTime = time;
        series->clear();
    }
    series->append(time-tempTime,_measurement->temperature);

    auto message = labelText + QString().setNum(_measurement->voltage, 'g', 4) + QString(" V ");
    message += QString(" Temperature:") + QString().setNum(_measurement->temperature) + QString(" Celsius");

    label->setText(message);
    QChart* chartToDelete=NULL;
    lastTime = time;

    if ((( lastTime - motorTriggerTime < measurementSpan ) && motorRun )|| !motorRun )
    {
        if(
           chartView->chart()
           )
        {
            chartToDelete=chartView->chart();
        }
        chartView->setChart(createChart());

        delete chartToDelete;
    }
}

void Widget::serviceMotorData(MotorData const * _motorData)
{
    float time = ((float)_motorData->time);
    if ( motorSeries->points().size() > 0 &&  motorSeries->points().back().x() > time )
    {
        motorSeries->clear();
    }
    motorSeries->append(time,_motorData->speed);
    auto message = QString("Motor Speed:  ") + QString().setNum(_motorData->speed, 'g', 4) + QString(" Rpm ");

    //label->setText(message);
    QChart* chartToDelete=NULL;
    if(motorChartView->chart())
    {
        chartToDelete=motorChartView->chart();
    }
    motorChartView->setChart(createMotorChart());

    delete chartToDelete;
}


Widget::~Widget()
{
}

