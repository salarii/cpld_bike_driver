#include "widget.h"
#include <QVBoxLayout>

using namespace QtCharts;

QString const labelText = "Current Voltage: ";

Widget::Widget(QWidget *parent)
    : QWidget(parent)
{


    QVBoxLayout *layout = new QVBoxLayout;

    this->setLayout(layout);

    chartView = new  QChartView(this);

    series = new QLineSeries();
    label = new QLabel("");

    chartView->setChart(createChart());
    layout->addWidget(chartView);
    layout->addWidget(label);

    idx = 0;
    this->setFixedSize(800, 800);
    this->adjustSize();
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
    newChart->setTitle("Voltage");
    newChart->addSeries(series);

    QValueAxis *axisX = new QValueAxis;
    //axisX->setTickInterval(10);

    newChart->addAxis(axisX, Qt::AlignBottom);

    QValueAxis *axisY = new QValueAxis;

    newChart->addAxis(axisY, Qt::AlignLeft);
    series->attachAxis(axisX);
    series->attachAxis(axisY);
    axisX->applyNiceNumbers();
    axisY->setRange(0.0, 2.0);
    axisY->applyNiceNumbers();
    return newChart;
}


void Widget::setValue(float _value)
{

    series->append(idx,_value);
    idx++;
    auto message = labelText + QString().setNum(_value, 'g', 4) + QString(" V ");

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

