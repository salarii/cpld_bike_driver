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

enum class SettingViewType{ speedRegulatorProfile1 = 0,speedRegulatorProfile2 = 1, termalRegulator = 2, otherStuff = 3 };

enum class SettingCodes{ speedKp1 = 0,speedKp2 =1,
                         speedKi1= 2, speedKi2= 3,
                         speedKd1 = 4, speedKd2 = 5,
                         maxSpeed1 =6, maxSpeed2 =7,
                         speedOffset1 = 8, speedOffset2 = 9,
                         temperatureKp = 10, temperatureKd = 11,
                         maxTemperature = 12, temperatureOffset = 13,
                         userLimit =14, alphaPedalAssist = 15, alphaSpeed = 16,last = 17};

const std::map<int, SettingCodes> rowToSpeed1SettingCode = {
        {0,SettingCodes::speedKp1},
        {1,SettingCodes::speedKi1},
        {2,SettingCodes::speedKd1},
        {3,SettingCodes::maxSpeed1},
        {4,SettingCodes::speedOffset1}
};

const std::map<int, SettingCodes> rowToSpeed2SettingCode = {
        {0,SettingCodes::speedKp2},
        {1,SettingCodes::speedKi2},
        {2,SettingCodes::speedKd2},
        {3,SettingCodes::maxSpeed2},
        {4,SettingCodes::speedOffset2}
};

const std::map<int, SettingCodes> rowToTemperatureSettingCode = {
        {0,SettingCodes::temperatureKp},
        {1,SettingCodes::temperatureKd},
        {2,SettingCodes::maxTemperature},
        {3,SettingCodes::temperatureOffset}
};

const std::map<int, SettingCodes> rowToOtherSettingCode = {
        {0,SettingCodes::userLimit},
        {1,SettingCodes::alphaPedalAssist},
        {2,SettingCodes::alphaSpeed}
};

class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

signals:
    void sendToHardware(unsigned char * _data, unsigned  _size);
    void reqVerifyFlash(int _idx);
    void reqFlashLoad(int _idx);
public slots:
    void verifyFlashAfterLoad();
    void flashDataView(int _idx);
	void initFlashLoad();
	void verifyFlash(int _idx);
    void sendDataToFlash(int _idx);
    void reloadCurrentFlashDataView();
    void requestDataFromFlash(int _idx);
    void displayFlash(FlashData const * _value);
    void serviceMeasurement(Measurement const * _value);
    void serviceMotorData(MotorData const * _motorData);
    void startMeasurement(bool _checked);
    void serialProblem();
    void startMotor(bool _checked);
    void setMeasurementChannel(int _index);
    void motorSliderChanged();
    void resetParameter();
private:
    QChart *  createChart();
    QChart * createMotorChart();
    void switchSettingsView(SettingViewType _settingView);

    unsigned char getParameterCode(int _idx);
    int getParameterCnt();
    unsigned int getColumnCode(int _idx);
    float settingToDevVal(int _idx,float _val);

private:
    bool motorRun;
    QLineSeries* series;
    QLineSeries* motorSeries;
    QChartView * chartView;
    QChartView * motorChartView;
    QLabel * label;
    QLabel * parLabels[SettingsPageCnt];
    QLineEdit * parLineEdit[SettingsPageCnt];
    QPushButton * parRestoreButton[SettingsPageCnt];
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
    std::vector<unsigned int> loadedDataReg;
    unsigned int fixedVal;

    int verifyIdx;
};
#endif // WIDGET_H
