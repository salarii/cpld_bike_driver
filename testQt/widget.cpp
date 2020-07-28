#include <QVBoxLayout>
#include <QTabWidget>
#include "widget.h"
#include "communication.h"
#include "data_types.h"
#include <QDoubleValidator>
#include <QThread>
#include <QTimer>
unsigned int const MainClockFreq = 1000000;

using namespace QtCharts;



const QStringList flashParamsMess ={
    "Speed regulator: ",
    "Termal regulator: "
};

QString const labelText = "Current Voltage: ";

#define FIXED_POINT_FRACTIONAL_BITS 8

unsigned  short floatToFixed(float input)
{
    return (unsigned  short)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

float fixedToFloat(unsigned  short input)
{
    return ((float)((signed short)input) / (float)(1 << FIXED_POINT_FRACTIONAL_BITS));
}


Widget::Widget(QWidget *parent)
    : QWidget(parent),motorRun(false)
{


    loadedDataReg.resize((int)SettingCodes::last);

    rotation_cnt =0;
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


    interfaceLayout->addWidget(title);
    interfaceLayout->addWidget(celsius);
    interfaceLayout->addWidget(unit);

    interfaceLayout->addWidget(adcChannelList);

    QWidget * flashWidget = new QWidget;
    QVBoxLayout *flashLayout = new QVBoxLayout;
    flashWidget->setLayout(flashLayout);
    auto titleFlash = new QLabel("Manage flash: ");



    parameterList = new QComboBox();
    QStringList params = { "speed regulator", "temperature regulator"};
    parameterList->addItems(params);
    QPushButton * saveFlash= new QPushButton("save to flash");



    QObject::connect(saveFlash, &QPushButton::clicked,
                     this, &Widget::initFlashLoad);
    
    QObject::connect(this, &Widget::reqFlashLoad,
                     this, &Widget::sendDataToFlash);
   /* QPushButton * loadFlash= new QPushButton("load from flash");*/
    QObject::connect(parameterList, QOverload<int>::of(&QComboBox::activated),
                     this, &Widget::flashDataView);

    flashLayout->addWidget(titleFlash);
    flashLayout->addWidget(parameterList);


    for (int i = 0 ;i < SettingsPageCnt ; i++)
    {
        QHBoxLayout *rowLayout = new QHBoxLayout;
        flashLayout->addLayout(rowLayout);

        parLabels[i] = new QLabel("");
        rowLayout->addWidget(parLabels[i]);
        parLineEdit[i] = new QLineEdit;
        parLineEdit[i]->setValidator(new QDoubleValidator);
        rowLayout->addWidget(parLineEdit[i]);
        parRestoreButton[i] = new QPushButton("Reset");
        rowLayout->addWidget(parRestoreButton[i]);

        QObject::connect(parRestoreButton[i], &QPushButton::pressed,
                         this, &Widget::resetParameter);
    }
    flashLayout->addWidget(saveFlash);
    switchSettingsView(SettingViewType::speedRegulatorProfile1);

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

    hal = new QCheckBox;
    QLabel * halLabel = new QLabel("Use hal: ");
    manual = new QCheckBox;
    QLabel * manualLabel = new QLabel("Use manual: ");
    QHBoxLayout * botLayout = new QHBoxLayout;

    botLayout->addWidget(halLabel);
    botLayout->addWidget(hal);
    botLayout->addWidget(manualLabel);
    botLayout->addWidget(manual);
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

    QObject::connect(this,&Widget::reqVerifyFlash,
                     this,&Widget::verifyFlash);



}


void
Widget::resetParameter()
{
    int idx = 0;
    for (int i = 0 ;i < SettingsPageCnt ; i++)
    {
       if ( parRestoreButton[i]->isDown() )
       {
            idx = i;
            break;
       }
    }

    sendBuff[0] = (unsigned  char)CommandCodes::EraseFlashOpCode;
    sendBuff[1] = getParameterCode(idx);
    emit sendToHardware(sendBuff, 2);
    QTimer::singleShot(500, this, SLOT(reloadCurrentFlashDataView()));
}

/*
auto symSet = rowToSpeedSettingCode;
if (settingView == SettingViewType::termalRegulator)
{
    symSet = rowToTemperatureSettingCode;
}


*/

void
Widget::reloadCurrentFlashDataView()
{

    requestDataFromFlash(0);
}

void
Widget::flashDataView(int _idx)
{
    if (_idx == 0)
    {
        switchSettingsView(SettingViewType::speedRegulatorProfile1);
    }
    else if(_idx == 1)
    {
        switchSettingsView(SettingViewType::speedRegulatorProfile2);
    }
    else if(_idx == 2)
    {
        switchSettingsView(SettingViewType::termalRegulator);
    }
    else if(_idx == 3)
    {
        switchSettingsView(SettingViewType::otherStuff);
    }
    requestDataFromFlash(0);
}

void
Widget::switchSettingsView(SettingViewType _settingView)
{
    if ( _settingView != settingView )
    {
        settingView = _settingView;
        if (_settingView == SettingViewType::speedRegulatorProfile1 ||
            _settingView == SettingViewType::speedRegulatorProfile2 )
        {
            parLabels[0]->setText("Kp");
            parLabels[1]->setText("Ki");
            parLabels[2]->setText("Kd");
            parLabels[3]->setText("Reg offset");
            parLabels[4]->setText("Maximum speed \nkm/h(0.36 m radius)");


        }
        else if ( _settingView == SettingViewType::termalRegulator )
        {
            parLabels[0]->setText("Kp");
            parLabels[1]->setText("Kd");
            parLabels[2]->setText("Reg offset");
            parLabels[3]->setText("Maximum temperature (celsius)");
            parLabels[4]->setText("");
        }
        else if ( _settingView == SettingViewType::otherStuff )
        {
            parLabels[0]->setText("user limit");
            parLabels[1]->setText("alpha pedal assist");
            parLabels[2]->setText("alpha speed");
            parLabels[3]->setText("");
            parLabels[4]->setText("");
        }
    }

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

float processFloat(  QVector<unsigned char> const & _data)
{

    unsigned short value = (unsigned int)_data[2] +
                         (((unsigned int)_data[1])<<8);


    float  floatVal = 0.0;

    floatVal = fixedToFloat(value);

    return floatVal;
}

unsigned short processUnsigned(  QVector<unsigned char> const & _data)
{
    unsigned short value = (unsigned int)_data[2] +
                         (((unsigned int)_data[1])<<8);

    return value;
}

void
Widget::displayFlash(FlashData const * _value)
{

    float val = 0.0;
    int  limit = 0;
    unsigned int  idx =  getColumnCode(_value->idx);

    loadedDataReg[_value->idx] = processUnsigned(_value->data);

    if (settingView == SettingViewType::speedRegulatorProfile1 ||
        settingView == SettingViewType::speedRegulatorProfile2 )
    {
        if (_value->idx == (int)SettingCodes::speedOffset1 ||
            _value->idx == (int)SettingCodes::speedOffset2 )
        {
            val = ((float)processUnsigned(_value->data))/16.0;
        }
        else if ( _value->idx == (int)SettingCodes::maxSpeed1 ||
                  _value->idx == (int)SettingCodes::maxSpeed2 )
        {
            val = processFloat(_value->data);
        }
        else
        {
            val = processFloat(_value->data);
        }
        limit = 4;
    }
    else if  (settingView == SettingViewType::termalRegulator)
    {
        if (_value->idx == (int)SettingCodes::temperatureOffset )
        {
            val = ((float)processUnsigned(_value->data))/16.0;
        }
        else if ( _value->idx == (int)SettingCodes::maxTemperature )
        {
            val = processUnsigned(_value->data);
        }
        else
        {
            val = processFloat(_value->data);
        }

        limit = 3;
    }
    else if (settingView == SettingViewType::otherStuff)
    {
        if (_value->idx == (int)SettingCodes::userLimit )
        {
            val = ((float)processUnsigned(_value->data))/16.0;
        }
        else
        {
            val = processUnsigned(_value->data);
        }

        limit = 2;
      }


    QString  valStr = QString().setNum(val,'g', 4);

    parLineEdit[idx]->setText(valStr);

    if (idx < limit )
    {
        requestDataFromFlash(idx + 1);
    }
}

void
Widget::requestDataFromFlash(int _idx)
{
    sendBuff[0] = (unsigned  char)CommandCodes::ReadFlashOpCode;
    sendBuff[1] = getParameterCode(_idx);
    emit sendToHardware(sendBuff, 2);

}


void
Widget::setMeasurementChannel(int _index)
{

    sendBuff[0] = (unsigned  char)CommandCodes::ChangeADCChannel;
    sendBuff[1] = _index;
    emit sendToHardware(sendBuff, 2);

}


unsigned int Widget::getColumnCode(int _idx)
{
    if (settingView == SettingViewType::speedRegulatorProfile1)
    {
        for( auto const& [key, val] : rowToSpeed1SettingCode )
        {
            if ((int)val == _idx)
            {
                return key;
            }
        }
        return 0;
    }
    else if  (settingView == SettingViewType::speedRegulatorProfile2)
    {
        for( auto const& [key, val] : rowToSpeed2SettingCode )
        {
            if ((int)val == _idx)
            {
                return key;
            }
        }
        return 0;
    }
    else if  (settingView == SettingViewType::termalRegulator)
    {
        for( auto const& [key, val] : rowToTemperatureSettingCode )
        {
            if ((int)val == _idx)
            {
                return key;
            }
        }
        return 0;
    }
    else if  (settingView == SettingViewType::otherStuff)
    {
        for( auto const& [key, val] : rowToOtherSettingCode )
        {
            if ((int)val == _idx)
            {
                return key;
            }
        }
        return 0;
    }
    return 0;
}

unsigned char Widget::getParameterCode(int _idx)
{
    if (settingView == SettingViewType::speedRegulatorProfile1)
    {
        return (unsigned char)rowToSpeed1SettingCode.find(_idx)->second;

    }
    else if  (settingView == SettingViewType::speedRegulatorProfile2)
    {

        return (unsigned char)rowToSpeed2SettingCode.find(_idx)->second;
    }
    else if  (settingView == SettingViewType::termalRegulator)
    {

        return (unsigned char)rowToTemperatureSettingCode.find(_idx)->second;
    }
    else if  (settingView == SettingViewType::otherStuff)
    {

        return (unsigned char)rowToOtherSettingCode.find(_idx)->second;
    }

    return 0;
}

int Widget::getParameterCnt()
{
    if (settingView == SettingViewType::speedRegulatorProfile1 ||
        settingView == SettingViewType::speedRegulatorProfile2 )
    {
        return 5;

    }
    else if  (settingView == SettingViewType::termalRegulator)
    {
        return 4;
    }
    else if  (settingView == SettingViewType::otherStuff)
    {
        return 3;
    }
    return 0;
}


void
Widget::sendDataToFlash(int _idx)
{
    bool bStatus = false;
   //
    int parameterCnt =getParameterCnt();
    if (_idx >= parameterCnt)
    {
        return;
    }

    unsigned char parameterIdx =getParameterCode(_idx);

    QString value = parLineEdit[_idx]->text();
    value = value.replace(",", ".");
    float val = value.toFloat(&bStatus);
    if ( bStatus == true )
    {
        fixedVal = floatToFixed(val);
        unsigned int val =loadedDataReg[getParameterCode(_idx)];

        if ( val != fixedVal)
        {
            sendBuff[0] = (unsigned  char)CommandCodes::WriteFlashOpCode;
            sendBuff[1] = parameterIdx;
            sendBuff[2] = 0x00;
            sendBuff[3] = (fixedVal  >> 8) & 0xff;
            sendBuff[4] = fixedVal & 0xff;

            emit sendToHardware(sendBuff, 5);
            emit reqVerifyFlash(_idx);
        }
        else
        {
            sendDataToFlash(_idx + 1);
        }
    }

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
            if (hal->isChecked())
            {
                sendBuff[4] = 1;
            }
            else
            {
                sendBuff[4] = 0;
            }
            if (manual->isChecked())
            {
                sendBuff[5] = 1;
            }
            else
            {
                sendBuff[5] = 0;
            }

            emit sendToHardware(sendBuff, 6);
        }
}

void 
Widget::initFlashLoad()
{
	emit reqFlashLoad(0);
}

void 
Widget::verifyFlash(int _idx)
{
    unsigned int  val = loadedDataReg[getParameterCode(_idx)];

    
    if (fixedVal == val)
    {
    	emit reqFlashLoad(_idx + 1);
        		
    }
    else
    {
        verifyIdx = _idx;
        QTimer::singleShot(500, this, SLOT(verifyFlashAfterLoad()));

    }
}
void Widget::verifyFlashAfterLoad()
{
    emit requestDataFromFlash(verifyIdx);
    emit reqVerifyFlash(verifyIdx);

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
        //tempTime = time;
    }
    if ( series->points().size() > 0 &&  series->points().back().x() > time )
    {
        tempTime = time;
        series->clear();
    }
    series->append(time-tempTime,_measurement->temperature);

    auto message = labelText + QString().setNum(_measurement->voltage, 'g', 4) + QString(" V ");
    message += QString(" Temperature:") + QString().setNum(_measurement->temperature) + QString(" Celsius");
    message += QString(" Rotation cnt:") + QString().setNum(rotation_cnt);
    message += QString(" Rpm speed:") + QString().setNum(speed);

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

    float time = ((float)_motorData->time)/1000.0;
    speed = _motorData->speed*60/250;

    if ( motorSeries->points().size() == 0 )
    {
        tempTime = time;
    }
    if ( motorSeries->points().size() > 0 &&  motorSeries->points().back().x() > time )
    {
        motorSeries->clear();
    }
    rotation_cnt = _motorData->rot_cnt;
    motorSeries->append(time,speed);

    lastTime = time;

    if ((( lastTime - motorTriggerTime < measurementMotorSpan ) && motorRun )|| !motorRun )
    {
        QChart* chartToDelete=NULL;
        if(motorChartView->chart())
        {
            chartToDelete=motorChartView->chart();
        }
        motorChartView->setChart(createMotorChart());

        delete chartToDelete;
    }

}


Widget::~Widget()
{
}

