#include <QVBoxLayout>
#include <QTabWidget>
#include "widget.h"
#include "communication.h"
#include "data_types.h"


unsigned int const MainClockFreq = 1000000;

using namespace QtCharts;

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
    layout->addWidget(chartView);
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
    QObject::connect(startButton, &QPushButton::clicked,
                     this, &Widget::startMeasurement);

    functionsTabs->addTab(triggerWidget, "Waveform");
    functionsTabs->setMaximumHeight(80);
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
Widget::startMeasurement(bool _checked)
{

    if ( _checked == false )
    {
        startButton->setText("Start");

        sendBuff[0] = StopOpCode;

        emit sendToHardware(sendBuff, 1);

    }
    else
    {
        startButton->setText("Stop");
        short unsigned freq;
        short unsigned pulse;

        freq = MainClockFreq/frequency->value();
        pulse = (pulseWidth->value()* freq)/100;

        sendBuff[0] = TriggerOpCode;
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

