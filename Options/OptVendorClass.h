/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *
 * released under GNU GPL v2 only licence
 */

#ifndef OPTVENDORCLASS_H
#define OPTVENDORCLASS_H

#include "OptUserClass.h"
#include <stdint.h>

class TOptVendorClass : public TOptUserClass
{
 public:
    friend std::ostream & operator<<(std::ostream & strum, TOptVendorClass &x);

    uint32_t Enterprise_id_;

    TOptVendorClass(const TOptVendorClass& copy);
    TOptVendorClass(uint16_t type, const char* buf, unsigned short buf_len, TMsg* parent);
    size_t getSize();
    char * storeSelf( char* buf);
};

#endif /* USERCLASS_H */
