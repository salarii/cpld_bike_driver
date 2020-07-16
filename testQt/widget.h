#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include "data_types.h"

#include <QtCharts>
#include <QLabel>
#include <QSpinBox>
#include <QPushButton>
#include <QSlider>
#include <QComboBox>
#include <QCheckBox>

const unsigned SettingsPageCnt = 5;

struct Measurement;
struct FlashData;
const unsigned char  polyBase = 0x0;

enum class SettingViewType{ speedRegulator = 0, termalRegulator = 1 };
enum class SettingCodes{ speedKp = 0,speedKi= 1, speedKd = 2,
                         temperatureKp = 3, temperatureKd = 4,
                         maxSpeed =5, speedOffset = 6,
                         maxTemperature = 7, temperatureOffset = 8};

const std::map<int, SettingCodes> rowToSpeedSettingCode = {
        {0,SettingCodes::speedKp},
        {1,SettingCodes::speedKi},
        {2,SettingCodes::speedKd},
        {3,SettingCodes::maxSpeed},
        {4,SettingCodes::speedOffset}
};

const std::map<int, SettingCodes> rowToTemperatureSettingCode = {
        {0,SettingCodes::temperatureKp},
        {1,SettingCodes::temperatureKd},
        {2,SettingCodes::maxTemperature},
        {3,SettingCodes::temperatureOffset}
};

class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

signals:
    void sendToHardware(unsigned char * _data, unsigned  _size);


public slots:
    void sendDataToFlash();
    void requestDataFromFlash();
    void displayFlash(FlashData const * _value);
    void serviceMeasurement(Measurement const * _value);
    void serviceMotorData(MotorData const * _motorData);
    void startMeasurement(bool _checked);
    void serialProblem();
    void startMotor(bool _checked);
    void setMeasurementChannel(int _index);
    void motorSliderChanged();
private:
    QChart *  createChart();
    QChart * createMotorChart();
    void switchSettingsView(SettingViewType _settingView);
private:
    bool motorRun;
    QLineSeries* series;
    QLineSeries* motorSeries;
    QChartView * chartView;
    QChartView * motorChartView;
    QLabel * label;
    QLabel * parLabels[SettingsPageCnt];
    QLineEdit * parLineEdit[SettingsPageCnt];
    QSpinBox * celsius;
    QSlider * sliderSpeed;
    QSlider * sliderForce;
    QLabel * labelSpeed;
    QLabel * labelForce;
    QPushButton * runMotorButton;
    QCheckBox * hal;
    QCheckBox * manual;
    QComboBox *  adcChannelList;

    QComboBox *  parameterList;
    unsigned char * sendBuff;

    float idx;

    const int measurementSpan =800;
    const int measurementMotorSpan =1000;
    int lastTime;
    int tempTime;
    int motorTriggerTime;
    int rotation_cnt;
    int speed;
    SettingViewType settingView;
    std::vector<unsigned int> loadedSpeedReg;
    std::vector<unsigned int> loadedTemperatureReg;
};
#endif // WIDGET_H
