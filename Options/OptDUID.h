/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 *
 * released under GNU GPL v2 only licence
 */

#ifndef OPTDUID_H
#define OPTDUID_H

#include "DHCPConst.h"
#include "Opt.h"
#include "DUID.h"
#include "SmartPtr.h"

class TOptDUID : public TOpt
{
  public:
    friend std::ostream & operator<<(std::ostream & strum, TOptDUID &x);
    TOptDUID(int type, SPtr<TDUID> duid, TMsg* parent);
    TOptDUID(int type, const char* buf, int len, TMsg* parent);
    TOptDUID(const TOptDUID& copy);
    size_t getSize();

    char * storeSelf(char* buf);
    bool doDuties() { return true; }
    SPtr<TDUID> getDUID() const;
    virtual bool isValid() const;
    virtual std::string getPlain();
  protected:
    SPtr<TDUID> DUID;
};

#endif
